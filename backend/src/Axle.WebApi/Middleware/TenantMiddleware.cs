using System.Security.Claims;
using Axle.Data;
using Microsoft.EntityFrameworkCore;

namespace Axle.Middleware;

/// <summary>
/// Middleware to extract and validate tenant context from HTTP requests.
/// Sets the TenantId in HttpContext.Items for use by downstream services and EF Core filters.
/// </summary>
public class TenantMiddleware
{
    private readonly RequestDelegate _next;
    private readonly ILogger<TenantMiddleware> _logger;

    public TenantMiddleware(RequestDelegate next, ILogger<TenantMiddleware> logger)
    {
        _next = next;
        _logger = logger;
    }

    public async Task InvokeAsync(HttpContext context, ApplicationDbContext dbContext)
    {
        Guid? tenantId = null;

        try
        {
            // Priority 1: Extract from X-Tenant-Id header (for API calls)
            if (context.Request.Headers.TryGetValue("X-Tenant-Id", out var tenantIdHeader))
            {
                if (Guid.TryParse(tenantIdHeader.ToString(), out var parsedTenantId))
                {
                    tenantId = parsedTenantId;
                    _logger.LogDebug("Extracted tenant ID from X-Tenant-Id header: {TenantId}", tenantId);
                }
            }

            // Priority 2: Extract from JWT claims (user's current tenant)
            if (tenantId == null && context.User.Identity?.IsAuthenticated == true)
            {
                var tenantClaim = context.User.FindFirst("tenant_id");
                if (tenantClaim != null && Guid.TryParse(tenantClaim.Value, out var claimTenantId))
                {
                    tenantId = claimTenantId;
                    _logger.LogDebug("Extracted tenant ID from JWT claim: {TenantId}", tenantId);
                }
            }

            // Priority 3: Extract from subdomain (e.g., acme.yourdomain.com)
            if (tenantId == null)
            {
                var host = context.Request.Host.Host;
                var parts = host.Split('.');

                // If subdomain exists (more than 2 parts, e.g., tenant.example.com)
                if (parts.Length > 2)
                {
                    var subdomain = parts[0];

                    // Look up tenant by slug (subdomain)
                    var tenant = await dbContext.Tenants
                        .AsNoTracking()
                        .FirstOrDefaultAsync(t => t.Slug == subdomain && t.IsActive);

                    if (tenant != null)
                    {
                        tenantId = tenant.Id;
                        _logger.LogDebug("Extracted tenant ID from subdomain '{Subdomain}': {TenantId}", subdomain, tenantId);
                    }
                }
            }

            // Priority 4: Extract from route parameter (e.g., /api/tenants/{tenantId}/work-items)
            if (tenantId == null && context.Request.RouteValues.TryGetValue("tenantId", out var routeTenantId))
            {
                if (Guid.TryParse(routeTenantId?.ToString(), out var parsedRouteTenantId))
                {
                    tenantId = parsedRouteTenantId;
                    _logger.LogDebug("Extracted tenant ID from route parameter: {TenantId}", tenantId);
                }
            }

            // Validate that tenant exists and is active (if tenant ID was found)
            if (tenantId.HasValue)
            {
                var tenantExists = await dbContext.Tenants
                    .AsNoTracking()
                    .AnyAsync(t => t.Id == tenantId.Value && t.IsActive);

                if (!tenantExists)
                {
                    _logger.LogWarning("Tenant validation failed: tenant {TenantId} not found or inactive", tenantId);
                    tenantId = null; // Reset invalid tenant
                }
            }

            // Store tenant ID in HttpContext.Items for access by services and EF Core
            if (tenantId.HasValue)
            {
                context.Items["TenantId"] = tenantId.Value;
                _logger.LogInformation("Tenant context set successfully: {TenantId} for path {Path}", tenantId.Value, context.Request.Path);
            }
            else
            {
                _logger.LogDebug("No tenant context available for request path {Path}", context.Request.Path);
            }
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "Tenant context extraction failed, continuing without tenant context");
            // Continue without tenant context rather than failing the request
        }

        await _next(context);
    }
}

/// <summary>
/// Extension methods for registering TenantMiddleware.
/// </summary>
public static class TenantMiddlewareExtensions
{
    public static IApplicationBuilder UseTenantMiddleware(this IApplicationBuilder builder)
    {
        return builder.UseMiddleware<TenantMiddleware>();
    }
}
