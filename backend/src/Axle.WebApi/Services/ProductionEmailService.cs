namespace Axle.Services;

/// <summary>
/// Production email service - implement with your preferred email provider
/// (SendGrid, AWS SES, Mailgun, etc.)
/// </summary>
public class ProductionEmailService : IEmailService
{
    private readonly ILogger<ProductionEmailService> _logger;
    private readonly IConfiguration _configuration;

    public ProductionEmailService(
        ILogger<ProductionEmailService> logger,
        IConfiguration configuration)
    {
        _logger = logger;
        _configuration = configuration;
    }

    public async Task SendVerificationEmailAsync(string email, string code, string userId)
    {
        // TODO: Implement with your email service provider
        // Example providers:
        // - SendGrid: https://sendgrid.com/
        // - AWS SES: https://aws.amazon.com/ses/
        // - Mailgun: https://www.mailgun.com/
        // - Azure Communication Services Email

        _logger.LogWarning(
            "ProductionEmailService.SendVerificationEmailAsync is not implemented. " +
            "Email: {Email}, UserId: {UserId}", email, userId);

        await Task.CompletedTask;

        // Example template:
        /*
        var emailBody = $@"
            <h1>Verify Your Email Address</h1>
            <p>Please use the following code to verify your email:</p>
            <h2>{code}</h2>
            <p>This code will expire in 24 hours.</p>
        ";

        await _emailProvider.SendAsync(
            to: email,
            subject: "Verify Your Email Address",
            htmlBody: emailBody
        );
        */
    }

    public async Task SendPasswordResetEmailAsync(string email, string code, string userId)
    {
        // TODO: Implement with your email service provider

        _logger.LogWarning(
            "ProductionEmailService.SendPasswordResetEmailAsync is not implemented. " +
            "Email: {Email}, UserId: {UserId}", email, userId);

        await Task.CompletedTask;
    }

    public string? GetLastVerificationCode(string email)
    {
        // Not available in production
        return null;
    }
}
