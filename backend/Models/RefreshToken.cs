namespace Axle.Models;

/// <summary>
/// Refresh token entity for JWT token refresh functionality.
/// </summary>
public class RefreshToken
{
    public int Id { get; set; }

    /// <summary>
    /// The refresh token string.
    /// </summary>
    public string Token { get; set; } = string.Empty;

    /// <summary>
    /// When the token expires.
    /// </summary>
    public DateTime ExpiresAt { get; set; }

    /// <summary>
    /// When the token was created.
    /// </summary>
    public DateTime CreatedAt { get; set; } = DateTime.UtcNow;

    /// <summary>
    /// Whether the token has been revoked.
    /// </summary>
    public bool IsRevoked { get; set; }

    /// <summary>
    /// When the token was revoked.
    /// </summary>
    public DateTime? RevokedAt { get; set; }

    /// <summary>
    /// User ID this token belongs to.
    /// </summary>
    public string UserId { get; set; } = string.Empty;

    /// <summary>
    /// Navigation property to user.
    /// </summary>
    public ApplicationUser User { get; set; } = null!;

    /// <summary>
    /// Check if token is active (not expired and not revoked).
    /// </summary>
    public bool IsActive => !IsRevoked && ExpiresAt > DateTime.UtcNow;
}
