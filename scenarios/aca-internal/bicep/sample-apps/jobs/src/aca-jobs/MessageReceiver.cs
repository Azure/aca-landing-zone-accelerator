using aca_jobs.Model;
using Azure.Identity;
using Azure.Messaging.ServiceBus;
using Microsoft.Extensions.Options;

namespace aca_jobs;

public class MessageReceiver : IJob
{
    private readonly ILogger<Program> _logger;
    private readonly ConfigurationOptions _settings;
    private readonly ServiceBusReceiver _receiver;

    public MessageReceiver(ILogger<Program> logger, IOptions<ConfigurationOptions> options)
    {
        _logger = logger;
        _settings = options.Value;
        
        var client = new ServiceBusClient(_settings.ServiceBusNamespace, 
            new DefaultAzureCredential());
        _receiver = client.CreateReceiver(_settings.OutputQueueName);
    }

    public async Task ExecuteAsync(CancellationToken stoppingToken)
    {
        _logger.LogInformation("Receiver running at: {time}", DateTimeOffset.Now);
        try
        {
            var numbers = await _receiver.ReceiveNumbersAsync(_settings.FetchCount,
                TimeSpan.FromSeconds(_settings.MaxWaitTime), stoppingToken);
            _logger.LogInformation("Received {Count} messages from the {Name} queue",
                numbers.Count, _settings.OutputQueueName);
            _logger.LogInformation("The numbers are: {Numbers}", string.Join(", ", numbers));
        }
        catch (Exception e)
        {
            _logger.LogError("An error occurred while receiving messages from the {Name} queue: {Error}",
                _settings.OutputQueueName, e.Message);
        }
    }
}

