using System.ComponentModel.DataAnnotations;

namespace Axle.DTOs;

/// <summary>
/// Request model for refreshing access token.
/// </summary>
public class RefreshTokenRequest
{
    [Required]
    public string RefreshToken { get; set; } = string.Empty;
}
