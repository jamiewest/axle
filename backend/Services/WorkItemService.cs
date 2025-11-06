using Axle.Data;
using Axle.Models;
using Microsoft.EntityFrameworkCore;

namespace Axle.Services;

/// <summary>
/// Implementation of IWorkItemService for managing work items.
/// </summary>
public class WorkItemService : IWorkItemService
{
    private readonly ApplicationDbContext _context;
    private readonly IHttpContextAccessor _httpContextAccessor;
    private readonly ILogger<WorkItemService> _logger;

    public WorkItemService(
        ApplicationDbContext context,
        IHttpContextAccessor httpContextAccessor,
        ILogger<WorkItemService> logger)
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

    public async Task<WorkItem?> GetByIdAsync(Guid id)
    {
        return await _context.WorkItems
            .Include(w => w.CreatedBy)
            .Include(w => w.ModifiedBy)
            .FirstOrDefaultAsync(w => w.Id == id);
    }

    public async Task<List<WorkItem>> GetAllAsync(string? type = null, Guid? parentId = null)
    {
        var query = _context.WorkItems
            .Include(w => w.CreatedBy)
            .Include(w => w.ModifiedBy)
            .AsQueryable();

        if (!string.IsNullOrEmpty(type))
        {
            query = query.Where(w => w.Type == type);
        }

        if (parentId.HasValue)
        {
            query = query.Where(w => w.ParentId == parentId.Value);
        }
        else
        {
            // If no parent ID specified, get root items only
            query = query.Where(w => w.ParentId == null);
        }

        return await query
            .OrderBy(w => w.CreatedAt)
            .ToListAsync();
    }

    public async Task<(List<WorkItem> Items, int TotalCount)> GetPagedAsync(
        int page = 1,
        int pageSize = 20,
        string? type = null,
        Guid? parentId = null,
        string? searchTerm = null)
    {
        var query = _context.WorkItems
            .Include(w => w.CreatedBy)
            .Include(w => w.ModifiedBy)
            .AsQueryable();

        if (!string.IsNullOrEmpty(type))
        {
            query = query.Where(w => w.Type == type);
        }

        if (parentId.HasValue)
        {
            query = query.Where(w => w.ParentId == parentId.Value);
        }

        if (!string.IsNullOrEmpty(searchTerm))
        {
            query = query.Where(w => w.Name.Contains(searchTerm));
        }

        var totalCount = await query.CountAsync();

        var items = await query
            .OrderByDescending(w => w.CreatedAt)
            .Skip((page - 1) * pageSize)
            .Take(pageSize)
            .ToListAsync();

        return (items, totalCount);
    }

    public async Task<WorkItem> CreateAsync(WorkItem workItem)
    {
        workItem.TenantId = CurrentTenantId;
        workItem.CreatedById = CurrentUserId;
        workItem.CreatedAt = DateTime.UtcNow;

        _context.WorkItems.Add(workItem);
        await _context.SaveChangesAsync();

        _logger.LogInformation("Created work item {Id} of type {Type} in tenant {TenantId}",
            workItem.Id, workItem.Type, workItem.TenantId);

        return workItem;
    }

    public async Task<WorkItem?> UpdateAsync(Guid id, WorkItem workItem)
    {
        var existing = await _context.WorkItems.FindAsync(id);
        if (existing == null)
        {
            return null;
        }

        // Update fields
        existing.Name = workItem.Name;
        existing.Type = workItem.Type;
        existing.Subtype = workItem.Subtype;
        existing.ParentId = workItem.ParentId;
        existing.Meta = workItem.Meta;
        existing.ModifiedAt = DateTime.UtcNow;
        existing.ModifiedById = CurrentUserId;

        await _context.SaveChangesAsync();

        _logger.LogInformation("Updated work item {Id} in tenant {TenantId}",
            id, existing.TenantId);

        return existing;
    }

    public async Task<bool> DeleteAsync(Guid id)
    {
        var workItem = await _context.WorkItems.FindAsync(id);
        if (workItem == null)
        {
            return false;
        }

        _context.WorkItems.Remove(workItem);
        await _context.SaveChangesAsync();

        _logger.LogInformation("Deleted work item {Id} in tenant {TenantId}",
            id, workItem.TenantId);

        return true;
    }

    public async Task<List<WorkItem>> GetChildrenAsync(Guid parentId)
    {
        return await _context.WorkItems
            .Include(w => w.CreatedBy)
            .Include(w => w.ModifiedBy)
            .Where(w => w.ParentId == parentId)
            .OrderBy(w => w.CreatedAt)
            .ToListAsync();
    }

    public async Task<List<WorkItem>> GetAncestorsAsync(Guid id)
    {
        var ancestors = new List<WorkItem>();
        var current = await _context.WorkItems.FindAsync(id);

        while (current?.ParentId != null)
        {
            current = await _context.WorkItems.FindAsync(current.ParentId);
            if (current != null)
            {
                ancestors.Insert(0, current); // Insert at beginning to maintain order
            }
        }

        return ancestors;
    }
}
