using System.Collections.Concurrent;

namespace Axle.Services;

/// <summary>
/// Fake email service for development that logs emails to console
/// and stores codes in memory for UI display
/// </summary>
public class FakeEmailService : IEmailService
{
    private readonly ILogger<FakeEmailService> _logger;
    private readonly ConcurrentDictionary<string, string> _verificationCodes = new();

    public FakeEmailService(ILogger<FakeEmailService> logger)
    {
        _logger = logger;
    }

    public Task SendVerificationEmailAsync(string email, string code, string userId)
    {
        _logger.LogInformation(
            "=== FAKE EMAIL SERVICE ===\n" +
            "To: {Email}\n" +
            "Subject: Verify Your Email Address\n" +
            "UserId: {UserId}\n" +
            "Verification Code: {Code}\n" +
            "========================",
            email, userId, code);

        // Store code for retrieval
        _verificationCodes[email] = code;

        return Task.CompletedTask;
    }

    public Task SendPasswordResetEmailAsync(string email, string code, string userId)
    {
        _logger.LogInformation(
            "=== FAKE EMAIL SERVICE ===\n" +
            "To: {Email}\n" +
            "Subject: Reset Your Password\n" +
            "UserId: {UserId}\n" +
            "Reset Code: {Code}\n" +
            "========================",
            email, userId, code);

        // Store code for retrieval
        _verificationCodes[email] = code;

        return Task.CompletedTask;
    }

    public string? GetLastVerificationCode(string email)
    {
        _verificationCodes.TryGetValue(email, out var code);
        return code;
    }
}
