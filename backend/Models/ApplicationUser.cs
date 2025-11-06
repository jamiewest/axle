using Microsoft.AspNetCore.Identity;

namespace Axle.Models;

/// <summary>
/// Application user entity extending IdentityUser with additional properties.
/// </summary>
public class ApplicationUser : IdentityUser
{
    /// <summary>
    /// User's full name or display name.
    /// </summary>
    public string? FullName { get; set; }

    /// <summary>
    /// Date and time when the user account was created.
    /// </summary>
    public DateTime CreatedAt { get; set; } = DateTime.UtcNow;

    /// <summary>
    /// The current active tenant ID for this user's session.
    /// Null if user hasn't selected a tenant context yet.
    /// </summary>
    public Guid? CurrentTenantId { get; set; }

    /// <summary>
    /// Refresh tokens for this user.
    /// </summary>
    public ICollection<RefreshToken> RefreshTokens { get; set; } = new List<RefreshToken>();

    /// <summary>
    /// Tenants this user belongs to.
    /// </summary>
    public ICollection<TenantUser> TenantMemberships { get; set; } = new List<TenantUser>();

    /// <summary>
    /// Work items created by this user.
    /// </summary>
    public ICollection<WorkItem> CreatedWorkItems { get; set; } = new List<WorkItem>();

    /// <summary>
    /// Work items last modified by this user.
    /// </summary>
    public ICollection<WorkItem> ModifiedWorkItems { get; set; } = new List<WorkItem>();
}
