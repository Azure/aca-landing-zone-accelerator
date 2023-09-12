using aca_jobs.Model;
using Azure.Identity;
using Azure.Messaging.ServiceBus;

namespace aca_jobs;

public class MessageProcessor : BackgroundService
{
    private readonly ILogger _logger;
    private readonly ConfigurationOptions _settings;
    private readonly ServiceBusReceiver _receiver;
    private readonly ServiceBusSender _sender;

    public MessageProcessor(ILogger logger, ConfigurationOptions settings)
    {
        _logger = logger;
        _settings = settings;
        var client = new ServiceBusClient(_settings.ServiceBusNamespace, 
            new DefaultAzureCredential());
        _receiver = client.CreateReceiver(_settings.InputQueueName);
        _sender = client.CreateSender(_settings.OutputQueueName);
    }

    protected override async Task ExecuteAsync(CancellationToken stoppingToken)
    {
        while (!stoppingToken.IsCancellationRequested)
        {
            _logger.LogInformation("Processor running at: {time}", DateTimeOffset.Now);

            var numbers = await _receiver.ReceiveNumbersAsync(_settings.FetchCount, TimeSpan.FromMinutes(_settings.MaxWaitTime),
                stoppingToken);
            
            foreach (var n in numbers)
            {
                await _sender.SendMessageAsync(
                    new ServiceBusMessage(Fibonacci(n).ToString()), stoppingToken);
            }
        }
    }
    
    //Fibonacci method
    private static int Fibonacci(int n)
    {
        if (n < 0) throw new ArgumentException("The number must be a positive integer", nameof(n));
        return n switch
        {
            0 => 0,
            1 => 1,
            _ => Fibonacci(n - 1) + Fibonacci(n - 2)
        };
    }
}

