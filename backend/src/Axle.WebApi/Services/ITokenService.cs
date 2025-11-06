using Axle.Models;

namespace Axle.Services;

/// <summary>
/// Service for generating and managing JWT tokens.
/// </summary>
public interface ITokenService
{
    /// <summary>
    /// Generate a JWT access token for a user.
    /// </summary>
    string GenerateAccessToken(ApplicationUser user, IList<string> roles);

    /// <summary>
    /// Generate a refresh token.
    /// </summary>
    RefreshToken GenerateRefreshToken(string userId);

    /// <summary>
    /// Validate a refresh token.
    /// </summary>
    Task<ApplicationUser?> ValidateRefreshTokenAsync(string token);

    /// <summary>
    /// Revoke a refresh token.
    /// </summary>
    Task RevokeRefreshTokenAsync(string token);
}
