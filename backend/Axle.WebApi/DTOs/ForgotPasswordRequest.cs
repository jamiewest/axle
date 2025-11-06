using System.ComponentModel.DataAnnotations;

namespace Axle.DTOs;

/// <summary>
/// Request model for forgot password.
/// </summary>
public class ForgotPasswordRequest
{
    [Required]
    [EmailAddress]
    public string Email { get; set; } = string.Empty;
}
