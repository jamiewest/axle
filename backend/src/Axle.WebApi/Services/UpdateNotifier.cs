using System.Collections.Concurrent;
using Axle.Grpc;

namespace Axle.Services;

/// <summary>
/// In-memory implementation of update notifier.
/// Manages subscriptions and broadcasts updates to subscribers.
/// </summary>
public class UpdateNotifier : IUpdateNotifier
{
    private readonly ConcurrentDictionary<string, List<Subscription>> _subscriptions = new();
    private readonly ILogger<UpdateNotifier> _logger;

    public UpdateNotifier(ILogger<UpdateNotifier> logger)
    {
        _logger = logger;
    }

    public async Task NotifyAsync(string dataType, ChangeType changeType, string data, Dictionary<string, string>? metadata = null)
    {
        if (!_subscriptions.TryGetValue(dataType, out var subscriptions))
        {
            return;
        }

        var updateMessage = new UpdateMessage
        {
            UpdateId = Guid.NewGuid().ToString(),
            DataType = dataType,
            ChangeType = changeType,
            Data = data,
            Timestamp = DateTimeOffset.UtcNow.ToUnixTimeMilliseconds()
        };

        if (metadata != null)
        {
            foreach (var kvp in metadata)
            {
                updateMessage.Metadata.Add(kvp.Key, kvp.Value);
            }
        }

        _logger.LogInformation("Broadcasting update for data type {DataType} to {SubscriberCount} subscribers",
            dataType, subscriptions.Count);

        // Create a copy to avoid modification during iteration
        var subscribersCopy = subscriptions.ToList();

        foreach (var subscription in subscribersCopy)
        {
            try
            {
                await subscription.Callback(updateMessage);
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Failed to notify subscriber {SubscriptionId}, removing subscription", subscription.Id);

                // Remove failed subscription
                subscriptions.Remove(subscription);
            }
        }
    }

    public string Subscribe(string dataType, Func<UpdateMessage, Task> callback)
    {
        var subscription = new Subscription
        {
            Id = Guid.NewGuid().ToString(),
            DataType = dataType,
            Callback = callback,
            CreatedAt = DateTime.UtcNow
        };

        _subscriptions.AddOrUpdate(
            dataType,
            new List<Subscription> { subscription },
            (_, existing) =>
            {
                existing.Add(subscription);
                return existing;
            });

        _logger.LogInformation("Subscription created successfully: {SubscriptionId} for data type {DataType}", subscription.Id, dataType);

        return subscription.Id;
    }

    public bool Unsubscribe(string subscriptionId)
    {
        foreach (var kvp in _subscriptions)
        {
            var subscription = kvp.Value.FirstOrDefault(s => s.Id == subscriptionId);
            if (subscription != null)
            {
                kvp.Value.Remove(subscription);
                _logger.LogInformation("Subscription removed successfully: {SubscriptionId}", subscriptionId);
                return true;
            }
        }

        return false;
    }

    private class Subscription
    {
        public string Id { get; set; } = string.Empty;
        public string DataType { get; set; } = string.Empty;
        public Func<UpdateMessage, Task> Callback { get; set; } = null!;
        public DateTime CreatedAt { get; set; }
    }
}
