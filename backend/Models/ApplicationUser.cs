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
    /// Refresh tokens for this user.
    /// </summary>
    public ICollection<RefreshToken> RefreshTokens { get; set; } = new List<RefreshToken>();
}
