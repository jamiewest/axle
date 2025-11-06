using System.ComponentModel.DataAnnotations;

namespace Axle.Models;

/// <summary>
/// Generic work item that can represent any entity (task, project, customer, etc.).
/// Custom fields are stored in the Meta JSON column and mapped to FieldDefinitions.
/// </summary>
public class WorkItem
{
    /// <summary>
    /// Unique identifier for the work item.
    /// </summary>
    public Guid Id { get; set; } = Guid.NewGuid();

    /// <summary>
    /// Tenant this work item belongs to (for data isolation).
    /// </summary>
    public Guid TenantId { get; set; }

    /// <summary>
    /// Navigation property to tenant.
    /// </summary>
    public Tenant Tenant { get; set; } = null!;

    /// <summary>
    /// Parent work item ID for hierarchical structures (null for root items).
    /// </summary>
    public Guid? ParentId { get; set; }

    /// <summary>
    /// Navigation property to parent work item.
    /// </summary>
    public WorkItem? Parent { get; set; }

    /// <summary>
    /// Child work items in the hierarchy.
    /// </summary>
    public ICollection<WorkItem> Children { get; set; } = new List<WorkItem>();

    /// <summary>
    /// Type of work item (e.g., "Task", "Project", "Customer", "Issue").
    /// This determines which FieldDefinitions apply.
    /// </summary>
    [Required]
    [MaxLength(100)]
    public string Type { get; set; } = string.Empty;

    /// <summary>
    /// Subtype for further categorization (e.g., "Bug", "Feature", "Epic").
    /// </summary>
    [MaxLength(100)]
    public string? Subtype { get; set; }

    /// <summary>
    /// Display name/title of the work item.
    /// </summary>
    [Required]
    [MaxLength(500)]
    public string Name { get; set; } = string.Empty;

    /// <summary>
    /// JSON blob containing all custom field values.
    /// Keys map to FieldDefinition.FieldKey, values are the actual data.
    /// Example: { "priority": "High", "due_date": "2024-12-31", "assignee_id": "user123" }
    /// </summary>
    public string? Meta { get; set; }

    /// <summary>
    /// When the work item was created.
    /// </summary>
    public DateTime CreatedAt { get; set; } = DateTime.UtcNow;

    /// <summary>
    /// User who created this work item.
    /// </summary>
    public string CreatedById { get; set; } = string.Empty;

    /// <summary>
    /// Navigation property to creator.
    /// </summary>
    public ApplicationUser CreatedBy { get; set; } = null!;

    /// <summary>
    /// When the work item was last modified.
    /// </summary>
    public DateTime? ModifiedAt { get; set; }

    /// <summary>
    /// User who last modified this work item.
    /// </summary>
    public string? ModifiedById { get; set; }

    /// <summary>
    /// Navigation property to last modifier.
    /// </summary>
    public ApplicationUser? ModifiedBy { get; set; }
}
