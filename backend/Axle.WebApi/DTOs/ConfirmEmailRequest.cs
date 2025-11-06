using System.ComponentModel.DataAnnotations;

namespace Axle.DTOs;

/// <summary>
/// Request model for email confirmation.
/// </summary>
public class ConfirmEmailRequest
{
    [Required]
    public string UserId { get; set; } = string.Empty;

    [Required]
    public string Code { get; set; } = string.Empty;
}
