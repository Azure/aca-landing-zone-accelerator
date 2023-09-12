using aca_jobs.Model;
using Azure.Identity;
using Azure.Messaging.ServiceBus;

namespace aca_jobs;

public class MessageSender : BackgroundService
{
    private readonly ILogger _logger;
    private readonly ConfigurationOptions _configuration;
    private readonly ServiceBusSender _messageSender;

    public MessageSender(ILogger logger, ConfigurationOptions configuration)
    {
        _logger = logger;
        _configuration = configuration;
        var client = new ServiceBusClient(_configuration.ServiceBusNamespace, 
            new DefaultAzureCredential());
        _messageSender = client.CreateSender(_configuration.InputQueueName);
    }

    protected override async Task ExecuteAsync(CancellationToken stoppingToken)
    {
        while (!stoppingToken.IsCancellationRequested)
        {
            _logger.LogInformation("Sender running at: {time}", DateTimeOffset.Now);
            switch (_configuration.SendType)
            {
                case "list":
                    await _messageSender.SendNumberListAsync(_configuration, _logger, stoppingToken);
                    break;
                case "batch":
                    await _messageSender.SendNumberBatchAsync(_configuration, _logger, stoppingToken);
                    break;
                default:
                    throw new ArgumentException(
                        "The send type argument needs to be either list or single");
            }
        }
    }
}

