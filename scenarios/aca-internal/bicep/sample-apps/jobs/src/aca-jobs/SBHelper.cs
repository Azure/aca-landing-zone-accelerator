using aca_jobs.Model;
using Azure.Messaging.ServiceBus;

namespace aca_jobs;

public static class SBHelper
{
    static SBHelper()
    {
        
    }
    
    public static async Task<IList<int>> ReceiveNumbersAsync(this ServiceBusReceiver receiver, int fetchCount, TimeSpan maxWaitTime, CancellationToken stoppingToken)
    {
        IList<int> fetchedMessages = new List<int>();        
        while (!stoppingToken.IsCancellationRequested)
        {
            var messages = await receiver.ReceiveMessagesAsync(
                fetchCount,
                maxWaitTime: maxWaitTime,
                stoppingToken);

            if (messages.Count == 0) break;
            foreach (var message in messages)
            {
                if (int.TryParse(message.Body.ToString(), out var number))
                {
                    fetchedMessages.Add(number);
                }
                await receiver.CompleteMessageAsync(message, stoppingToken);
            }
        }
        return fetchedMessages;    
    }
    
    public static async Task SendNumberBatchAsync(this ServiceBusSender sender, ConfigurationOptions configuration, 
        ILogger logger, CancellationToken stoppingToken)
    {
        var batchMessage = await sender.CreateMessageBatchAsync(stoppingToken);

        for (int i = 0; i < configuration.MessageCount; i++)
        {
            batchMessage.TryAddMessage(
                new ServiceBusMessage($"{new Random().Next(configuration.MinNumber, configuration.MaxNumber)}"));
        }
        try
        {
            await sender.SendMessagesAsync(batchMessage, stoppingToken);
            logger.LogInformation("Sent a batch of {Count} messages to the {Name} queue",
                configuration.MessageCount, configuration.InputQueueName);
        }
        catch (Exception e)
        {
            logger.LogError("An error occurred while sending a batch message to the {Name} queue: {Error}",
                configuration.InputQueueName, e.Message);
        }
        
    }

    public static async Task SendNumberListAsync(this ServiceBusSender sender, ConfigurationOptions configuration, 
    ILogger logger, CancellationToken stoppingToken)
    {
        List<ServiceBusMessage> messages = new();
        for (int i = 0; i < configuration.MessageCount; i++)
        {
            messages.Add(new ServiceBusMessage(
                $"{new Random().Next(configuration.MinNumber, configuration.MaxNumber)}"));
        }
        try
        {
            await sender.SendMessagesAsync(messages, stoppingToken);
            logger.LogInformation("Sent a list of {Count} messages to the {Name} queue",
                configuration.MessageCount, configuration.InputQueueName);
        }
        catch (Exception e)
        {
            logger.LogError("An error occurred while sending messages to the {Name} queue: {Error}",
                configuration.InputQueueName, e.Message);
        }
    }

    public static Task SendNumberAsync(this ServiceBusSender sender, int number)
    {
        ServiceBusMessage message = new ServiceBusMessage(number.ToString());
        return sender.SendMessageAsync(message);
    }
}