using System.ComponentModel.DataAnnotations;

namespace Axle.DTOs;

/// <summary>
/// Request model for user registration.
/// </summary>
public class RegisterRequest
{
    [Required]
    [EmailAddress]
    public string Email { get; set; } = string.Empty;

    [Required]
    [MinLength(6)]
    public string Password { get; set; } = string.Empty;

    public string? UserName { get; set; }
}
