using aca_jobs.Model;
using Azure.Identity;
using Azure.Messaging.ServiceBus;

namespace aca_jobs;

public class MessageReceiver : BackgroundService
{
    private readonly ILogger _logger;
    private readonly ConfigurationOptions _settings;
    private readonly ServiceBusReceiver _receiver;

    public MessageReceiver(ILogger logger, ConfigurationOptions settings)
    {
        _logger = logger;
        _settings = settings;
        
        var client = new ServiceBusClient(_settings.ServiceBusNamespace, 
            new DefaultAzureCredential());
    }

    protected override async Task ExecuteAsync(CancellationToken stoppingToken)
    {
        while (!stoppingToken.IsCancellationRequested)
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
}

