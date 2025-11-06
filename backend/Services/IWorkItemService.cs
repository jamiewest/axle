using Axle.Models;

namespace Axle.Services;

/// <summary>
/// Service for managing work items with tenant isolation.
/// </summary>
public interface IWorkItemService
{
    /// <summary>
    /// Gets a work item by ID (tenant-scoped).
    /// </summary>
    Task<WorkItem?> GetByIdAsync(Guid id);

    /// <summary>
    /// Gets all work items for the current tenant, optionally filtered by type.
    /// </summary>
    Task<List<WorkItem>> GetAllAsync(string? type = null, Guid? parentId = null);

    /// <summary>
    /// Gets work items with pagination.
    /// </summary>
    Task<(List<WorkItem> Items, int TotalCount)> GetPagedAsync(
        int page = 1,
        int pageSize = 20,
        string? type = null,
        Guid? parentId = null,
        string? searchTerm = null);

    /// <summary>
    /// Creates a new work item.
    /// </summary>
    Task<WorkItem> CreateAsync(WorkItem workItem);

    /// <summary>
    /// Updates an existing work item.
    /// </summary>
    Task<WorkItem?> UpdateAsync(Guid id, WorkItem workItem);

    /// <summary>
    /// Deletes a work item.
    /// </summary>
    Task<bool> DeleteAsync(Guid id);

    /// <summary>
    /// Gets children of a work item (hierarchical).
    /// </summary>
    Task<List<WorkItem>> GetChildrenAsync(Guid parentId);

    /// <summary>
    /// Gets the full hierarchy path from root to item.
    /// </summary>
    Task<List<WorkItem>> GetAncestorsAsync(Guid id);
}
