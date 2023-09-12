using aca_jobs.Model;
using Microsoft.Extensions.Options;

namespace aca_jobs;

public class BackroundJob : BackgroundService
{
    private readonly ILogger _logger;
    private readonly IOptions<ConfigurationOptions> _settings;

    public BackroundJob(ILogger<Program> logger, IOptions<ConfigurationOptions> settings)
    {
        _logger = logger;
        _settings = settings;
    }
    
    protected override Task ExecuteAsync(CancellationToken stoppingToken)
    {
        BackgroundService service;
        switch (_settings.Value.WorkerRole)
        {
            case "sender":
                service = new MessageSender(_logger, _settings.Value);
                break;
            case "receiver":
                service = new MessageReceiver(_logger, _settings.Value);
                break;
            case "processor":
                service = new MessageProcessor(_logger, _settings.Value);
                break;
            default:
                throw new ArgumentException(
                    "The role argument needs to be either sender, receiver or processor");
        }
        return service.StartAsync(stoppingToken);
    }
}