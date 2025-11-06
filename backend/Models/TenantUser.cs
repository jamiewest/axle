namespace Axle.Models;

/// <summary>
/// Junction table linking users to tenants with roles.
/// Allows users to belong to multiple tenants.
/// </summary>
public class TenantUser
{
    /// <summary>
    /// Unique identifier.
    /// </summary>
    public Guid Id { get; set; } = Guid.NewGuid();

    /// <summary>
    /// Reference to the tenant.
    /// </summary>
    public Guid TenantId { get; set; }

    /// <summary>
    /// Navigation property to tenant.
    /// </summary>
    public Tenant Tenant { get; set; } = null!;

    /// <summary>
    /// Reference to the user (Identity user ID).
    /// </summary>
    public string UserId { get; set; } = string.Empty;

    /// <summary>
    /// Navigation property to user.
    /// </summary>
    public ApplicationUser User { get; set; } = null!;

    /// <summary>
    /// User's role within this tenant (Owner, Admin, Member, etc.).
    /// </summary>
    public string Role { get; set; } = TenantRole.Member;

    /// <summary>
    /// When the user joined this tenant.
    /// </summary>
    public DateTime JoinedAt { get; set; } = DateTime.UtcNow;

    /// <summary>
    /// Whether the user is active in this tenant.
    /// </summary>
    public bool IsActive { get; set; } = true;
}

/// <summary>
/// Predefined tenant roles.
/// </summary>
public static class TenantRole
{
    public const string Owner = "Owner";
    public const string Admin = "Admin";
    public const string Member = "Member";
    public const string Viewer = "Viewer";
}
