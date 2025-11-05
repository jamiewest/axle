using System.IdentityModel.Tokens.Jwt;
using System.Text;
using Axle.Grpc;
using Axle.Services;
using Grpc.Core;
using Microsoft.IdentityModel.Tokens;

namespace Axle.Grpc.Services;

/// <summary>
/// gRPC service for streaming real-time updates to clients.
/// </summary>
public class UpdateStreamService : UpdateStream.UpdateStreamBase
{
    private readonly IUpdateNotifier _updateNotifier;
    private readonly IConfiguration _configuration;
    private readonly ILogger<UpdateStreamService> _logger;

    public UpdateStreamService(
        IUpdateNotifier updateNotifier,
        IConfiguration configuration,
        ILogger<UpdateStreamService> logger)
    {
        _updateNotifier = updateNotifier;
        _configuration = configuration;
        _logger = logger;
    }

    public override async Task Subscribe(
        SubscribeRequest request,
        IServerStreamWriter<UpdateMessage> responseStream,
        ServerCallContext context)
    {
        _logger.LogInformation("Client subscribing to {DataType}", request.DataType);

        // Validate token
        if (!await ValidateTokenAsync(request.Token))
        {
            throw new RpcException(new Status(StatusCode.Unauthenticated, "Invalid or expired token"));
        }

        // Create a channel for this subscription
        var channel = System.Threading.Channels.Channel.CreateUnbounded<UpdateMessage>();

        // Register subscription with the notifier
        var subscriptionId = _updateNotifier.Subscribe(request.DataType, async (updateMessage) =>
        {
            // Apply filter if provided
            if (!string.IsNullOrEmpty(request.Filter))
            {
                // Simple filter check - can be enhanced
                if (!ApplyFilter(updateMessage, request.Filter))
                {
                    return;
                }
            }

            await channel.Writer.WriteAsync(updateMessage);
        });

        _logger.LogInformation("Created subscription {SubscriptionId} for {DataType}",
            subscriptionId, request.DataType);

        try
        {
            // Send initial connection confirmation
            await responseStream.WriteAsync(new UpdateMessage
            {
                UpdateId = subscriptionId,
                DataType = "system",
                ChangeType = ChangeType.Updated,
                Data = $"{{\"message\":\"Connected\",\"subscriptionId\":\"{subscriptionId}\"}}",
                Timestamp = DateTimeOffset.UtcNow.ToUnixTimeMilliseconds()
            });

            // Stream updates to the client
            await foreach (var message in channel.Reader.ReadAllAsync(context.CancellationToken))
            {
                await responseStream.WriteAsync(message);
                _logger.LogDebug("Sent update {UpdateId} to client", message.UpdateId);
            }
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "Error in subscription {SubscriptionId}", subscriptionId);
        }
        finally
        {
            // Cleanup subscription
            _updateNotifier.Unsubscribe(subscriptionId);
            channel.Writer.Complete();
            _logger.LogInformation("Subscription {SubscriptionId} ended", subscriptionId);
        }
    }

    public override Task<UnsubscribeResponse> Unsubscribe(
        UnsubscribeRequest request,
        ServerCallContext context)
    {
        var success = _updateNotifier.Unsubscribe(request.SubscriptionId);

        return Task.FromResult(new UnsubscribeResponse
        {
            Success = success,
            Message = success ? "Unsubscribed successfully" : "Subscription not found"
        });
    }

    private async Task<bool> ValidateTokenAsync(string token)
    {
        if (string.IsNullOrEmpty(token))
        {
            return false;
        }

        try
        {
            var jwtSettings = _configuration.GetSection("JwtSettings");
            var secretKey = jwtSettings["SecretKey"];

            if (string.IsNullOrEmpty(secretKey))
            {
                _logger.LogError("JWT SecretKey not configured");
                return false;
            }

            var tokenHandler = new JwtSecurityTokenHandler();
            var validationParameters = new TokenValidationParameters
            {
                ValidateIssuer = true,
                ValidateAudience = true,
                ValidateLifetime = true,
                ValidateIssuerSigningKey = true,
                ValidIssuer = jwtSettings["Issuer"],
                ValidAudience = jwtSettings["Audience"],
                IssuerSigningKey = new SymmetricSecurityKey(Encoding.UTF8.GetBytes(secretKey))
            };

            await tokenHandler.ValidateTokenAsync(token, validationParameters);
            return true;
        }
        catch (Exception ex)
        {
            _logger.LogWarning(ex, "Token validation failed");
            return false;
        }
    }

    private bool ApplyFilter(UpdateMessage message, string filter)
    {
        // Simple filter implementation
        // Can be enhanced with more complex filtering logic
        // For now, just check if the data contains the filter string
        return message.Data.Contains(filter, StringComparison.OrdinalIgnoreCase);
    }
}
