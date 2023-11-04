using aca_jobs.Model;
using Azure.Identity;
using Azure.Messaging.ServiceBus;
using Microsoft.Extensions.Options;

namespace aca_jobs;

public class MessageSender : IJob
{
    private readonly ILogger<Program>  _logger;
    private readonly ConfigurationOptions _configuration;
    private readonly ServiceBusSender _messageSender;

    public MessageSender(ILogger<Program>  logger, IOptions<ConfigurationOptions> options)
    {
        _logger = logger;
        _configuration = options.Value;
        var client = new ServiceBusClient(_configuration.ServiceBusNamespace, 
            new DefaultAzureCredential());
        _messageSender = client.CreateSender(_configuration.InputQueueName);
    }

    public async Task ExecuteAsync(CancellationToken stoppingToken)
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

