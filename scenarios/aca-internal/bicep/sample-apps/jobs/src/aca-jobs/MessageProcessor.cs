using aca_jobs.Model;
using Azure.Identity;
using Azure.Messaging.ServiceBus;
using Microsoft.Extensions.Options;

namespace aca_jobs;

public class MessageProcessor : IJob
{
    private readonly ILogger<Program>  _logger;
    private readonly ConfigurationOptions _settings;
    private readonly ServiceBusReceiver _receiver;
    private readonly ServiceBusSender _sender;

    public MessageProcessor(ILogger<Program>  logger, IOptions<ConfigurationOptions> options)
    {
        _logger = logger;
        _settings = options.Value;
        var client = new ServiceBusClient(_settings.ServiceBusNamespace, 
            new DefaultAzureCredential());
        _receiver = client.CreateReceiver(_settings.InputQueueName);
        _sender = client.CreateSender(_settings.OutputQueueName);
    }

    public async Task ExecuteAsync(CancellationToken stoppingToken)
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

