using Axle.Data;
using Axle.Models;
using Microsoft.EntityFrameworkCore;

namespace Axle.Services;

/// <summary>
/// Implementation of INodeService for managing nodes.
/// </summary>
public class NodeService : INodeService
{
    private readonly ApplicationDbContext _context;
    private readonly IHttpContextAccessor _httpContextAccessor;
    private readonly ILogger<NodeService> _logger;

    public NodeService(
        ApplicationDbContext context,
        IHttpContextAccessor httpContextAccessor,
        ILogger<NodeService> logger)
    {
        _context = context;
        _httpContextAccessor = httpContextAccessor;
        _logger = logger;
    }

    private Guid CurrentTenantId =>
        _httpContextAccessor.HttpContext?.Items["TenantId"] as Guid?
        ?? throw new InvalidOperationException("Tenant context not available");

    private string CurrentUserId =>
        _httpContextAccessor.HttpContext?.User.FindFirst(System.Security.Claims.ClaimTypes.NameIdentifier)?.Value
        ?? throw new InvalidOperationException("User context not available");

    public async Task<Node?> GetByIdAsync(Guid id)
    {
        return await _context.Nodes
            .Include(n => n.CreatedBy)
            .Include(n => n.ModifiedBy)
            .FirstOrDefaultAsync(n => n.Id == id);
    }

    public async Task<List<Node>> GetAllAsync(string? type = null, Guid? parentId = null)
    {
        var query = _context.Nodes
            .Include(n => n.CreatedBy)
            .Include(n => n.ModifiedBy)
            .AsQueryable();

        if (!string.IsNullOrEmpty(type))
        {
            query = query.Where(n => n.Type == type);
        }

        if (parentId.HasValue)
        {
            query = query.Where(n => n.ParentId == parentId.Value);
        }
        else
        {
            // If no parent ID specified, get root items only
            query = query.Where(n => n.ParentId == null);
        }

        return await query
            .OrderBy(n => n.CreatedAt)
            .ToListAsync();
    }

    public async Task<(List<Node> Items, int TotalCount)> GetPagedAsync(
        int page = 1,
        int pageSize = 20,
        string? type = null,
        Guid? parentId = null,
        string? searchTerm = null)
    {
        var query = _context.Nodes
            .Include(n => n.CreatedBy)
            .Include(n => n.ModifiedBy)
            .AsQueryable();

        if (!string.IsNullOrEmpty(type))
        {
            query = query.Where(n => n.Type == type);
        }

        if (parentId.HasValue)
        {
            query = query.Where(n => n.ParentId == parentId.Value);
        }

        if (!string.IsNullOrEmpty(searchTerm))
        {
            query = query.Where(n => n.Name.Contains(searchTerm));
        }

        var totalCount = await query.CountAsync();

        var items = await query
            .OrderByDescending(n => n.CreatedAt)
            .Skip((page - 1) * pageSize)
            .Take(pageSize)
            .ToListAsync();

        return (items, totalCount);
    }

    public async Task<Node> CreateAsync(Node node)
    {
        node.TenantId = CurrentTenantId;
        node.CreatedById = CurrentUserId;
        node.CreatedAt = DateTime.UtcNow;

        _context.Nodes.Add(node);
        await _context.SaveChangesAsync();

        _logger.LogInformation("Created node {Id} of type {Type} in tenant {TenantId}",
            node.Id, node.Type, node.TenantId);

        return node;
    }

    public async Task<Node?> UpdateAsync(Guid id, Node node)
    {
        var existing = await _context.Nodes.FindAsync(id);
        if (existing == null)
        {
            return null;
        }

        // Update fields
        existing.Name = node.Name;
        existing.Type = node.Type;
        existing.Subtype = node.Subtype;
        existing.ParentId = node.ParentId;
        existing.Meta = node.Meta;
        existing.ModifiedAt = DateTime.UtcNow;
        existing.ModifiedById = CurrentUserId;

        await _context.SaveChangesAsync();

        _logger.LogInformation("Updated node {Id} in tenant {TenantId}",
            id, existing.TenantId);

        return existing;
    }

    public async Task<bool> DeleteAsync(Guid id)
    {
        var node = await _context.Nodes.FindAsync(id);
        if (node == null)
        {
            return false;
        }

        _context.Nodes.Remove(node);
        await _context.SaveChangesAsync();

        _logger.LogInformation("Deleted node {Id} in tenant {TenantId}",
            id, node.TenantId);

        return true;
    }

    public async Task<List<Node>> GetChildrenAsync(Guid parentId)
    {
        return await _context.Nodes
            .Include(n => n.CreatedBy)
            .Include(n => n.ModifiedBy)
            .Where(n => n.ParentId == parentId)
            .OrderBy(n => n.CreatedAt)
            .ToListAsync();
    }

    public async Task<List<Node>> GetAncestorsAsync(Guid id)
    {
        var ancestors = new List<Node>();
        var current = await _context.Nodes.FindAsync(id);

        while (current?.ParentId != null)
        {
            current = await _context.Nodes.FindAsync(current.ParentId);
            if (current != null)
            {
                ancestors.Insert(0, current); // Insert at beginning to maintain order
            }
        }

        return ancestors;
    }
}
