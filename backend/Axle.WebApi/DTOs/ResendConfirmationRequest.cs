using System.ComponentModel.DataAnnotations;

namespace Axle.DTOs;

/// <summary>
/// Request model for resending email confirmation.
/// </summary>
public class ResendConfirmationRequest
{
    [Required]
    [EmailAddress]
    public string Email { get; set; } = string.Empty;
}
