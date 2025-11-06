using Axle.Models;

namespace Axle.Services;

/// <summary>
/// Service for managing nodes with tenant isolation.
/// </summary>
public interface INodeService
{
    /// <summary>
    /// Gets a node by ID (tenant-scoped).
    /// </summary>
    Task<Node?> GetByIdAsync(Guid id);

    /// <summary>
    /// Gets all nodes for the current tenant, optionally filtered by type.
    /// </summary>
    Task<List<Node>> GetAllAsync(string? type = null, Guid? parentId = null);

    /// <summary>
    /// Gets nodes with pagination.
    /// </summary>
    Task<(List<Node> Items, int TotalCount)> GetPagedAsync(
        int page = 1,
        int pageSize = 20,
        string? type = null,
        Guid? parentId = null,
        string? searchTerm = null);

    /// <summary>
    /// Creates a new node.
    /// </summary>
    Task<Node> CreateAsync(Node node);

    /// <summary>
    /// Updates an existing node.
    /// </summary>
    Task<Node?> UpdateAsync(Guid id, Node node);

    /// <summary>
    /// Deletes a node.
    /// </summary>
    Task<bool> DeleteAsync(Guid id);

    /// <summary>
    /// Gets children of a node (hierarchical).
    /// </summary>
    Task<List<Node>> GetChildrenAsync(Guid parentId);

    /// <summary>
    /// Gets the full hierarchy path from root to item.
    /// </summary>
    Task<List<Node>> GetAncestorsAsync(Guid id);
}
