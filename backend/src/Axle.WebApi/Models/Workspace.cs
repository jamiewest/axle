using System.ComponentModel.DataAnnotations;

namespace Axle.Models;

/// <summary>
/// Workspace entity that organizes nodes within a tenant.
/// Provides an additional layer of organization between tenants and nodes.
/// </summary>
public class Workspace
{
    /// <summary>
    /// Unique identifier for the workspace.
    /// </summary>
    [Key]
    public Guid Id { get; set; }

    /// <summary>
    /// The tenant this workspace belongs to.
    /// </summary>
    [Required]
    public Guid TenantId { get; set; }

    /// <summary>
    /// Name of the workspace.
    /// </summary>
    [Required]
    [MaxLength(200)]
    public string Name { get; set; } = string.Empty;

    /// <summary>
    /// Optional description of the workspace.
    /// </summary>
    [MaxLength(1000)]
    public string? Description { get; set; }

    /// <summary>
    /// Whether this workspace is active.
    /// </summary>
    public bool IsActive { get; set; } = true;

    /// <summary>
    /// Date and time when the workspace was created.
    /// </summary>
    [Required]
    public DateTime CreatedAt { get; set; } = DateTime.UtcNow;

    /// <summary>
    /// ID of the user who created this workspace.
    /// </summary>
    [Required]
    public string CreatedById { get; set; } = string.Empty;

    /// <summary>
    /// Date and time when the workspace was last updated.
    /// </summary>
    public DateTime? UpdatedAt { get; set; }

    /// <summary>
    /// ID of the user who last updated this workspace.
    /// </summary>
    public string? UpdatedById { get; set; }

    // Navigation properties

    /// <summary>
    /// The tenant this workspace belongs to.
    /// </summary>
    public Tenant? Tenant { get; set; }

    /// <summary>
    /// The user who created this workspace.
    /// </summary>
    public ApplicationUser? CreatedBy { get; set; }

    /// <summary>
    /// The user who last updated this workspace.
    /// </summary>
    public ApplicationUser? UpdatedBy { get; set; }

    /// <summary>
    /// Nodes that belong to this workspace.
    /// </summary>
    public ICollection<Node> Nodes { get; set; } = new List<Node>();
}
