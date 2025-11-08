using System.Text.Json;
using Axle.Data;
using Axle.DTOs;
using Axle.Models;
using Axle.Services;
using Microsoft.AspNetCore.Identity;
using Microsoft.EntityFrameworkCore;

namespace Axle.Extensions;

public static class EndpointExtensions
{
    public static WebApplication MapTenantEndpoints(this WebApplication app)
    {
        var tenants = app.MapGroup("/api/tenants").RequireAuthorization();

        // GET /api/tenants - List all tenants for current user
        tenants.MapGet("/", async (
            HttpContext context,
            ApplicationDbContext dbContext) =>
        {
            var userId = context.User.FindFirst(System.Security.Claims.ClaimTypes.NameIdentifier)?.Value;
            if (string.IsNullOrEmpty(userId))
            {
                return Results.Unauthorized();
            }

            var userTenants = await dbContext.TenantUsers
                .Include(tu => tu.Tenant)
                .Where(tu => tu.UserId == userId && tu.IsActive && tu.Tenant.IsActive)
                .Select(tu => new TenantResponse(
                    tu.Tenant.Id,
                    tu.Tenant.Name,
                    tu.Tenant.Slug,
                    tu.Tenant.IsActive,
                    tu.Tenant.Settings,
                    tu.Tenant.CreatedAt,
                    tu.Tenant.UpdatedAt
                ))
                .ToListAsync();

            return Results.Ok(userTenants);
        });

        // POST /api/tenants - Create new tenant
        tenants.MapPost("/", async (
            CreateTenantRequest request,
            HttpContext context,
            ApplicationDbContext dbContext) =>
        {
            var userId = context.User.FindFirst(System.Security.Claims.ClaimTypes.NameIdentifier)?.Value;
            if (string.IsNullOrEmpty(userId))
            {
                return Results.Unauthorized();
            }

            var tenant = new Tenant
            {
                Name = request.Name,
                Slug = request.Slug,
                Settings = request.Settings
            };

            dbContext.Tenants.Add(tenant);

            // Add creator as owner
            var tenantUser = new TenantUser
            {
                TenantId = tenant.Id,
                UserId = userId,
                Role = TenantRole.Owner
            };

            dbContext.TenantUsers.Add(tenantUser);
            await dbContext.SaveChangesAsync();

            var response = new TenantResponse(
                tenant.Id,
                tenant.Name,
                tenant.Slug,
                tenant.IsActive,
                tenant.Settings,
                tenant.CreatedAt,
                tenant.UpdatedAt
            );

            return Results.Created($"/api/tenants/{tenant.Id}", response);
        });

        // GET /api/tenants/{id} - Get tenant by ID
        tenants.MapGet("/{id:guid}", async (
            Guid id,
            ApplicationDbContext dbContext) =>
        {
            var tenant = await dbContext.Tenants.FindAsync(id);
            if (tenant == null)
            {
                return Results.NotFound();
            }

            var response = new TenantResponse(
                tenant.Id,
                tenant.Name,
                tenant.Slug,
                tenant.IsActive,
                tenant.Settings,
                tenant.CreatedAt,
                tenant.UpdatedAt
            );

            return Results.Ok(response);
        });

        // PUT /api/tenants/{id} - Update tenant
        tenants.MapPut("/{id:guid}", async (
            Guid id,
            UpdateTenantRequest request,
            ApplicationDbContext dbContext,
            ILogger<Program> logger) =>
        {
            var tenant = await dbContext.Tenants.FindAsync(id);
            if (tenant == null)
            {
                return Results.NotFound();
            }

            // Check if slug is being changed and if new slug already exists
            if (tenant.Slug != request.Slug)
            {
                var slugExists = await dbContext.Tenants
                    .AnyAsync(t => t.Slug == request.Slug && t.Id != id);

                if (slugExists)
                {
                    return Results.BadRequest(new
                    {
                        message = "A tenant with this slug already exists",
                        errors = new Dictionary<string, string[]>
                        {
                            { "slug", new[] { "This slug is already in use" } }
                        }
                    });
                }
            }

            // Update tenant properties
            tenant.Name = request.Name;
            tenant.Slug = request.Slug;
            tenant.IsActive = request.IsActive;
            tenant.Settings = request.Settings;
            tenant.UpdatedAt = DateTime.UtcNow;

            try
            {
                await dbContext.SaveChangesAsync();

                logger.LogInformation("Tenant {TenantId} updated successfully", tenant.Id);

                var response = new TenantResponse(
                    tenant.Id,
                    tenant.Name,
                    tenant.Slug,
                    tenant.IsActive,
                    tenant.Settings,
                    tenant.CreatedAt,
                    tenant.UpdatedAt
                );

                return Results.Ok(response);
            }
            catch (Exception ex)
            {
                logger.LogError(ex, "Error updating tenant {TenantId}", id);
                return Results.Problem("Failed to update tenant");
            }
        });

        return app;
    }

    public static WebApplication MapNodeEndpoints(this WebApplication app)
    {
        var nodes = app.MapGroup("/api/nodes").RequireAuthorization();

        // GET /api/nodes - List nodes with pagination and filters
        nodes.MapGet("/", async (
            HttpContext context,
            INodeService nodeService,
            int page = 1,
            int pageSize = 20,
            string? type = null,
            string? parentId = null,
            string? search = null) =>
        {
            Guid? parentGuid = null;
            if (!string.IsNullOrEmpty(parentId) && Guid.TryParse(parentId, out var parsedParentId))
            {
                parentGuid = parsedParentId;
            }

            var (items, totalCount) = await nodeService.GetPagedAsync(
                page, pageSize, type, parentGuid, search);

            var responses = items.Select(n => new NodeResponse(
                n.Id,
                n.TenantId,
                n.WorkspaceId,
                n.ParentId,
                n.Type,
                n.Subtype,
                n.Name,
                string.IsNullOrEmpty(n.Meta)
                    ? null
                    : JsonSerializer.Deserialize<Dictionary<string, object>>(n.Meta),
                n.CreatedAt,
                n.CreatedById,
                n.CreatedBy?.FullName,
                n.ModifiedAt,
                n.ModifiedById,
                n.ModifiedBy?.FullName
            )).ToList();

            var response = new NodeListResponse(responses, totalCount, page, pageSize);
            return Results.Ok(response);
        });

        // GET /api/nodes/{id} - Get single node
        nodes.MapGet("/{id:guid}", async (
            Guid id,
            INodeService nodeService) =>
        {
            var node = await nodeService.GetByIdAsync(id);
            if (node == null)
            {
                return Results.NotFound();
            }

            var response = new NodeResponse(
                node.Id,
                node.TenantId,
                node.WorkspaceId,
                node.ParentId,
                node.Type,
                node.Subtype,
                node.Name,
                string.IsNullOrEmpty(node.Meta)
                    ? null
                    : JsonSerializer.Deserialize<Dictionary<string, object>>(node.Meta),
                node.CreatedAt,
                node.CreatedById,
                node.CreatedBy?.FullName,
                node.ModifiedAt,
                node.ModifiedById,
                node.ModifiedBy?.FullName
            );

            return Results.Ok(response);
        });

        // POST /api/nodes - Create new node
        nodes.MapPost("/", async (
            CreateNodeRequest request,
            INodeService nodeService) =>
        {
            var node = new Node
            {
                Type = request.Type,
                Subtype = request.Subtype,
                Name = request.Name,
                WorkspaceId = request.WorkspaceId,
                ParentId = request.ParentId,
                Meta = request.Meta != null
                    ? JsonSerializer.Serialize(request.Meta)
                    : null
            };

            var created = await nodeService.CreateAsync(node);

            var response = new NodeResponse(
                created.Id,
                created.TenantId,
                created.WorkspaceId,
                created.ParentId,
                created.Type,
                created.Subtype,
                created.Name,
                request.Meta,
                created.CreatedAt,
                created.CreatedById,
                created.CreatedBy?.FullName,
                created.ModifiedAt,
                created.ModifiedById,
                created.ModifiedBy?.FullName
            );

            return Results.Created($"/api/nodes/{created.Id}", response);
        });

        // PUT /api/nodes/{id} - Update node
        nodes.MapPut("/{id:guid}", async (
            Guid id,
            UpdateNodeRequest request,
            INodeService nodeService) =>
        {
            var node = new Node
            {
                Type = request.Type,
                Subtype = request.Subtype,
                Name = request.Name,
                ParentId = request.ParentId,
                Meta = request.Meta != null
                    ? JsonSerializer.Serialize(request.Meta)
                    : null
            };

            var updated = await nodeService.UpdateAsync(id, node);
            if (updated == null)
            {
                return Results.NotFound();
            }

            var response = new NodeResponse(
                updated.Id,
                updated.TenantId,
                updated.WorkspaceId,
                updated.ParentId,
                updated.Type,
                updated.Subtype,
                updated.Name,
                string.IsNullOrEmpty(updated.Meta)
                    ? null
                    : JsonSerializer.Deserialize<Dictionary<string, object>>(updated.Meta),
                updated.CreatedAt,
                updated.CreatedById,
                updated.CreatedBy?.FullName,
                updated.ModifiedAt,
                updated.ModifiedById,
                updated.ModifiedBy?.FullName
            );

            return Results.Ok(response);
        });

        // DELETE /api/nodes/{id} - Delete node
        nodes.MapDelete("/{id:guid}", async (
            Guid id,
            INodeService nodeService) =>
        {
            var deleted = await nodeService.DeleteAsync(id);
            if (!deleted)
            {
                return Results.NotFound();
            }

            return Results.NoContent();
        });

        // GET /api/nodes/{id}/children - Get children of node
        nodes.MapGet("/{id:guid}/children", async (
            Guid id,
            INodeService nodeService) =>
        {
            var children = await nodeService.GetChildrenAsync(id);

            var responses = children.Select(n => new NodeResponse(
                n.Id,
                n.TenantId,
                n.WorkspaceId,
                n.ParentId,
                n.Type,
                n.Subtype,
                n.Name,
                string.IsNullOrEmpty(n.Meta)
                    ? null
                    : JsonSerializer.Deserialize<Dictionary<string, object>>(n.Meta),
                n.CreatedAt,
                n.CreatedById,
                n.CreatedBy?.FullName,
                n.ModifiedAt,
                n.ModifiedById,
                n.ModifiedBy?.FullName
            )).ToList();

            return Results.Ok(responses);
        });

        return app;
    }

    public static WebApplication MapFieldDefinitionEndpoints(this WebApplication app)
    {
        var fields = app.MapGroup("/api/field-definitions").RequireAuthorization();

        // GET /api/field-definitions - List all field definitions for current tenant
        fields.MapGet("/", async (
            IFieldDefinitionService fieldDefinitionService,
            string? entityType = null) =>
        {
            var definitions = string.IsNullOrEmpty(entityType)
                ? await fieldDefinitionService.GetAllAsync()
                : await fieldDefinitionService.GetByEntityTypeAsync(entityType);

            var responses = definitions.Select(fd => new FieldDefinitionResponse(
                fd.Id,
                fd.TenantId,
                fd.EntityType,
                fd.FieldName,
                fd.FieldKey,
                fd.FieldType,
                fd.DisplayOrder,
                fd.IsRequired,
                fd.IsEnabled,
                string.IsNullOrEmpty(fd.ValidationRules)
                    ? null
                    : JsonSerializer.Deserialize<Dictionary<string, object>>(fd.ValidationRules),
                string.IsNullOrEmpty(fd.UiMetadata)
                    ? null
                    : JsonSerializer.Deserialize<Dictionary<string, object>>(fd.UiMetadata),
                fd.CreatedAt,
                fd.UpdatedAt
            )).ToList();

            return Results.Ok(responses);
        });

        // GET /api/field-definitions/{id} - Get single field definition
        fields.MapGet("/{id:guid}", async (
            Guid id,
            IFieldDefinitionService fieldDefinitionService) =>
        {
            var fieldDefinition = await fieldDefinitionService.GetByIdAsync(id);
            if (fieldDefinition == null)
            {
                return Results.NotFound();
            }

            var response = new FieldDefinitionResponse(
                fieldDefinition.Id,
                fieldDefinition.TenantId,
                fieldDefinition.EntityType,
                fieldDefinition.FieldName,
                fieldDefinition.FieldKey,
                fieldDefinition.FieldType,
                fieldDefinition.DisplayOrder,
                fieldDefinition.IsRequired,
                fieldDefinition.IsEnabled,
                string.IsNullOrEmpty(fieldDefinition.ValidationRules)
                    ? null
                    : JsonSerializer.Deserialize<Dictionary<string, object>>(fieldDefinition.ValidationRules),
                string.IsNullOrEmpty(fieldDefinition.UiMetadata)
                    ? null
                    : JsonSerializer.Deserialize<Dictionary<string, object>>(fieldDefinition.UiMetadata),
                fieldDefinition.CreatedAt,
                fieldDefinition.UpdatedAt
            );

            return Results.Ok(response);
        });

        // POST /api/field-definitions - Create new field definition
        fields.MapPost("/", async (
            CreateFieldDefinitionRequest request,
            IFieldDefinitionService fieldDefinitionService) =>
        {
            var fieldDefinition = new FieldDefinition
            {
                EntityType = request.EntityType,
                FieldName = request.FieldName,
                FieldKey = request.FieldKey,
                FieldType = request.FieldType,
                DisplayOrder = request.DisplayOrder,
                IsRequired = request.IsRequired,
                IsEnabled = request.IsEnabled,
                ValidationRules = request.ValidationRules != null
                    ? JsonSerializer.Serialize(request.ValidationRules)
                    : null,
                UiMetadata = request.UiMetadata != null
                    ? JsonSerializer.Serialize(request.UiMetadata)
                    : null
            };

            var created = await fieldDefinitionService.CreateAsync(fieldDefinition);

            var response = new FieldDefinitionResponse(
                created.Id,
                created.TenantId,
                created.EntityType,
                created.FieldName,
                created.FieldKey,
                created.FieldType,
                created.DisplayOrder,
                created.IsRequired,
                created.IsEnabled,
                request.ValidationRules,
                request.UiMetadata,
                created.CreatedAt,
                created.UpdatedAt
            );

            return Results.Created($"/api/field-definitions/{created.Id}", response);
        });

        // PUT /api/field-definitions/{id} - Update field definition
        fields.MapPut("/{id:guid}", async (
            Guid id,
            UpdateFieldDefinitionRequest request,
            IFieldDefinitionService fieldDefinitionService) =>
        {
            var fieldDefinition = new FieldDefinition
            {
                FieldName = request.FieldName,
                FieldKey = request.FieldKey,
                FieldType = request.FieldType,
                DisplayOrder = request.DisplayOrder,
                IsRequired = request.IsRequired,
                IsEnabled = request.IsEnabled,
                ValidationRules = request.ValidationRules != null
                    ? JsonSerializer.Serialize(request.ValidationRules)
                    : null,
                UiMetadata = request.UiMetadata != null
                    ? JsonSerializer.Serialize(request.UiMetadata)
                    : null
            };

            var updated = await fieldDefinitionService.UpdateAsync(id, fieldDefinition);
            if (updated == null)
            {
                return Results.NotFound();
            }

            var response = new FieldDefinitionResponse(
                updated.Id,
                updated.TenantId,
                updated.EntityType,
                updated.FieldName,
                updated.FieldKey,
                updated.FieldType,
                updated.DisplayOrder,
                updated.IsRequired,
                updated.IsEnabled,
                string.IsNullOrEmpty(updated.ValidationRules)
                    ? null
                    : JsonSerializer.Deserialize<Dictionary<string, object>>(updated.ValidationRules),
                string.IsNullOrEmpty(updated.UiMetadata)
                    ? null
                    : JsonSerializer.Deserialize<Dictionary<string, object>>(updated.UiMetadata),
                updated.CreatedAt,
                updated.UpdatedAt
            );

            return Results.Ok(response);
        });

        // DELETE /api/field-definitions/{id} - Soft delete field definition
        fields.MapDelete("/{id:guid}", async (
            Guid id,
            IFieldDefinitionService fieldDefinitionService) =>
        {
            var deleted = await fieldDefinitionService.DeleteAsync(id);
            if (!deleted)
            {
                return Results.NotFound();
            }

            return Results.NoContent();
        });

        // POST /api/field-definitions/reorder - Reorder fields
        fields.MapPost("/reorder", async (
            string entityType,
            ReorderFieldsRequest request,
            IFieldDefinitionService fieldDefinitionService) =>
        {
            await fieldDefinitionService.ReorderAsync(entityType, request.FieldIds);
            return Results.Ok(new { message = "Fields reordered successfully" });
        });

        // POST /api/field-definitions/{id}/validate - Validate a field value
        fields.MapPost("/{id:guid}/validate", async (
            Guid id,
            ValidateFieldValueRequest request,
            IFieldDefinitionService fieldDefinitionService) =>
        {
            var (isValid, errors) = await fieldDefinitionService.ValidateFieldValueAsync(id, request.Value);

            var response = new ValidateFieldValueResponse(isValid, errors);
            return Results.Ok(response);
        });

        return app;
    }

    public static WebApplication MapWorkspaceEndpoints(this WebApplication app)
    {
        var workspaces = app.MapGroup("/api/workspaces").RequireAuthorization();

        // GET /api/workspaces - List workspaces with pagination and filters
        workspaces.MapGet("/", async (
            HttpContext context,
            ApplicationDbContext dbContext,
            string? tenantId = null,
            int page = 1,
            int pageSize = 50,
            bool? isActive = null) =>
        {
            var userId = context.User.FindFirst(System.Security.Claims.ClaimTypes.NameIdentifier)?.Value;
            if (string.IsNullOrEmpty(userId))
            {
                return Results.Unauthorized();
            }

            if (string.IsNullOrEmpty(tenantId))
            {
                return Results.BadRequest(new { message = "TenantId is required" });
            }

            if (!Guid.TryParse(tenantId, out var tenantGuid))
            {
                return Results.BadRequest(new { message = "Invalid TenantId format" });
            }

            // Verify user has access to this tenant
            var hasAccess = await dbContext.TenantUsers
                .AnyAsync(tu => tu.TenantId == tenantGuid && tu.UserId == userId && tu.IsActive);

            if (!hasAccess)
            {
                return Results.Forbid();
            }

            var query = dbContext.Workspaces
                .Include(w => w.CreatedBy)
                .Include(w => w.UpdatedBy)
                .Where(w => w.TenantId == tenantGuid);

            if (isActive.HasValue)
            {
                query = query.Where(w => w.IsActive == isActive.Value);
            }

            var totalCount = await query.CountAsync();
            var items = await query
                .OrderByDescending(w => w.CreatedAt)
                .Skip((page - 1) * pageSize)
                .Take(pageSize)
                .ToListAsync();

            var responses = items.Select(w => new WorkspaceResponse(
                w.Id,
                w.TenantId,
                w.Name,
                w.Description,
                w.IsActive,
                w.CreatedAt,
                w.CreatedById,
                w.CreatedBy?.FullName,
                w.UpdatedAt,
                w.UpdatedById,
                w.UpdatedBy?.FullName
            )).ToList();

            var response = new WorkspaceListResponse(responses, totalCount, page, pageSize);
            return Results.Ok(response);
        });

        // GET /api/workspaces/{id} - Get single workspace
        workspaces.MapGet("/{id:guid}", async (
            Guid id,
            HttpContext context,
            ApplicationDbContext dbContext) =>
        {
            var userId = context.User.FindFirst(System.Security.Claims.ClaimTypes.NameIdentifier)?.Value;
            if (string.IsNullOrEmpty(userId))
            {
                return Results.Unauthorized();
            }

            var workspace = await dbContext.Workspaces
                .Include(w => w.CreatedBy)
                .Include(w => w.UpdatedBy)
                .FirstOrDefaultAsync(w => w.Id == id);

            if (workspace == null)
            {
                return Results.NotFound();
            }

            // Verify user has access to this workspace's tenant
            var hasAccess = await dbContext.TenantUsers
                .AnyAsync(tu => tu.TenantId == workspace.TenantId && tu.UserId == userId && tu.IsActive);

            if (!hasAccess)
            {
                return Results.Forbid();
            }

            var response = new WorkspaceResponse(
                workspace.Id,
                workspace.TenantId,
                workspace.Name,
                workspace.Description,
                workspace.IsActive,
                workspace.CreatedAt,
                workspace.CreatedById,
                workspace.CreatedBy?.FullName,
                workspace.UpdatedAt,
                workspace.UpdatedById,
                workspace.UpdatedBy?.FullName
            );

            return Results.Ok(response);
        });

        // POST /api/workspaces - Create new workspace
        workspaces.MapPost("/", async (
            CreateWorkspaceRequest request,
            HttpContext context,
            ApplicationDbContext dbContext,
            ILogger<Program> logger) =>
        {
            var userId = context.User.FindFirst(System.Security.Claims.ClaimTypes.NameIdentifier)?.Value;
            if (string.IsNullOrEmpty(userId))
            {
                return Results.Unauthorized();
            }

            // Verify user has access to the tenant
            var hasAccess = await dbContext.TenantUsers
                .AnyAsync(tu => tu.TenantId == request.TenantId && tu.UserId == userId && tu.IsActive);

            if (!hasAccess)
            {
                return Results.Forbid();
            }

            var workspace = new Workspace
            {
                TenantId = request.TenantId,
                Name = request.Name,
                Description = request.Description,
                CreatedById = userId
            };

            dbContext.Workspaces.Add(workspace);
            await dbContext.SaveChangesAsync();

            logger.LogInformation("Workspace {WorkspaceId} created by user {UserId}", workspace.Id, userId);

            // Reload to get navigation properties
            await dbContext.Entry(workspace).Reference(w => w.CreatedBy).LoadAsync();

            var response = new WorkspaceResponse(
                workspace.Id,
                workspace.TenantId,
                workspace.Name,
                workspace.Description,
                workspace.IsActive,
                workspace.CreatedAt,
                workspace.CreatedById,
                workspace.CreatedBy?.FullName,
                workspace.UpdatedAt,
                workspace.UpdatedById,
                null
            );

            return Results.Created($"/api/workspaces/{workspace.Id}", response);
        });

        // PUT /api/workspaces/{id} - Update workspace
        workspaces.MapPut("/{id:guid}", async (
            Guid id,
            UpdateWorkspaceRequest request,
            HttpContext context,
            ApplicationDbContext dbContext,
            ILogger<Program> logger) =>
        {
            var userId = context.User.FindFirst(System.Security.Claims.ClaimTypes.NameIdentifier)?.Value;
            if (string.IsNullOrEmpty(userId))
            {
                return Results.Unauthorized();
            }

            var workspace = await dbContext.Workspaces.FindAsync(id);
            if (workspace == null)
            {
                return Results.NotFound();
            }

            // Verify user has access to the workspace's tenant
            var hasAccess = await dbContext.TenantUsers
                .AnyAsync(tu => tu.TenantId == workspace.TenantId && tu.UserId == userId && tu.IsActive);

            if (!hasAccess)
            {
                return Results.Forbid();
            }

            // Update workspace properties
            workspace.Name = request.Name;
            workspace.Description = request.Description;
            if (request.IsActive.HasValue)
            {
                workspace.IsActive = request.IsActive.Value;
            }
            workspace.UpdatedAt = DateTime.UtcNow;
            workspace.UpdatedById = userId;

            try
            {
                await dbContext.SaveChangesAsync();

                logger.LogInformation("Workspace {WorkspaceId} updated by user {UserId}", workspace.Id, userId);

                // Reload to get navigation properties
                await dbContext.Entry(workspace).Reference(w => w.CreatedBy).LoadAsync();
                await dbContext.Entry(workspace).Reference(w => w.UpdatedBy).LoadAsync();

                var response = new WorkspaceResponse(
                    workspace.Id,
                    workspace.TenantId,
                    workspace.Name,
                    workspace.Description,
                    workspace.IsActive,
                    workspace.CreatedAt,
                    workspace.CreatedById,
                    workspace.CreatedBy?.FullName,
                    workspace.UpdatedAt,
                    workspace.UpdatedById,
                    workspace.UpdatedBy?.FullName
                );

                return Results.Ok(response);
            }
            catch (Exception ex)
            {
                logger.LogError(ex, "Error updating workspace {WorkspaceId}", id);
                return Results.Problem("Failed to update workspace");
            }
        });

        // DELETE /api/workspaces/{id} - Delete workspace
        workspaces.MapDelete("/{id:guid}", async (
            Guid id,
            HttpContext context,
            ApplicationDbContext dbContext,
            ILogger<Program> logger) =>
        {
            var userId = context.User.FindFirst(System.Security.Claims.ClaimTypes.NameIdentifier)?.Value;
            if (string.IsNullOrEmpty(userId))
            {
                return Results.Unauthorized();
            }

            var workspace = await dbContext.Workspaces.FindAsync(id);
            if (workspace == null)
            {
                return Results.NotFound();
            }

            // Verify user has access to the workspace's tenant
            var hasAccess = await dbContext.TenantUsers
                .AnyAsync(tu => tu.TenantId == workspace.TenantId && tu.UserId == userId && tu.IsActive);

            if (!hasAccess)
            {
                return Results.Forbid();
            }

            // Check if workspace has nodes
            var hasNodes = await dbContext.Nodes.AnyAsync(n => n.WorkspaceId == id);
            if (hasNodes)
            {
                return Results.BadRequest(new
                {
                    message = "Cannot delete workspace that contains nodes",
                    errors = new Dictionary<string, string[]>
                    {
                        { "workspace", new[] { "Workspace must be empty before deletion" } }
                    }
                });
            }

            try
            {
                dbContext.Workspaces.Remove(workspace);
                await dbContext.SaveChangesAsync();

                logger.LogInformation("Workspace {WorkspaceId} deleted by user {UserId}", id, userId);

                return Results.NoContent();
            }
            catch (Exception ex)
            {
                logger.LogError(ex, "Error deleting workspace {WorkspaceId}", id);
                return Results.Problem("Failed to delete workspace");
            }
        });

        return app;
    }
}
