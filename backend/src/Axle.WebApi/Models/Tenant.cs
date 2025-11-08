using System.ComponentModel.DataAnnotations;

namespace Axle.Models;

/// <summary>
/// Represents a tenant in the multi-tenant system.
/// Each tenant has isolated data and custom field configurations.
/// </summary>
public class Tenant
{
    /// <summary>
    /// Unique identifier for the tenant.
    /// </summary>
    public Guid Id { get; set; } = Guid.NewGuid();

    /// <summary>
    /// Display name of the tenant/organization.
    /// </summary>
    [Required]
    [MaxLength(200)]
    public string Name { get; set; } = string.Empty;

    /// <summary>
    /// URL-friendly slug for the tenant (e.g., acme-corp).
    /// </summary>
    [Required]
    [MaxLength(100)]
    public string Slug { get; set; } = string.Empty;

    /// <summary>
    /// Whether the tenant is active and can be accessed.
    /// </summary>
    public bool IsActive { get; set; } = true;

    /// <summary>
    /// JSON blob for tenant-specific settings and configuration.
    /// </summary>
    public string? Settings { get; set; }

    /// <summary>
    /// When the tenant was created.
    /// </summary>
    public DateTime CreatedAt { get; set; } = DateTime.UtcNow;

    /// <summary>
    /// When the tenant was last modified.
    /// </summary>
    public DateTime? UpdatedAt { get; set; }

    /// <summary>
    /// Users associated with this tenant.
    /// </summary>
    public ICollection<TenantUser> TenantUsers { get; set; } = new List<TenantUser>();

    /// <summary>
    /// Workspaces belonging to this tenant.
    /// </summary>
    public ICollection<Workspace> Workspaces { get; set; } = new List<Workspace>();

    /// <summary>
    /// Nodes belonging to this tenant.
    /// </summary>
    public ICollection<Node> Nodes { get; set; } = new List<Node>();

    /// <summary>
    /// Field definitions for this tenant.
    /// </summary>
    public ICollection<FieldDefinition> FieldDefinitions { get; set; } = new List<FieldDefinition>();
}
