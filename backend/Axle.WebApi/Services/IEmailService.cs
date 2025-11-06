namespace Axle.Services;

/// <summary>
/// Interface for email services
/// </summary>
public interface IEmailService
{
    /// <summary>
    /// Sends an email verification code to the specified email address
    /// </summary>
    /// <param name="email">Recipient email address</param>
    /// <param name="code">Verification code to send</param>
    /// <param name="userId">User ID for reference</param>
    /// <returns>Task that completes when email is sent</returns>
    Task SendVerificationEmailAsync(string email, string code, string userId);

    /// <summary>
    /// Sends a password reset email
    /// </summary>
    /// <param name="email">Recipient email address</param>
    /// <param name="code">Reset code to send</param>
    /// <param name="userId">User ID for reference</param>
    /// <returns>Task that completes when email is sent</returns>
    Task SendPasswordResetEmailAsync(string email, string code, string userId);

    /// <summary>
    /// Gets the last sent verification code for development/testing purposes
    /// </summary>
    /// <param name="email">Email address to check</param>
    /// <returns>Last verification code sent, or null if not available</returns>
    string? GetLastVerificationCode(string email);
}
