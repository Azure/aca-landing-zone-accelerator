using aca_jobs.Model;
using Microsoft.Extensions.Options;

namespace aca_jobs;

public class Program
{
    public static async Task Main(string[] args)
    {
        var host = CreateHostBuilder(args).Build();
        var myService = host.Services.GetRequiredService<IJob>();
        await myService.ExecuteAsync(new CancellationToken());
    }
    
    public static IHostBuilder CreateHostBuilder(string[] args) =>
        Host.CreateDefaultBuilder(args)
            .ConfigureServices((hostContext, services) =>
            {
                services.AddLogging(logging =>
                {
                    logging.ClearProviders();
                    logging.AddConfiguration(hostContext.Configuration.GetSection("Logging"));
                    logging.AddConsole();
                });
                var configSection = hostContext.Configuration.GetSection("settings");
                services.Configure<ConfigurationOptions>(configSection);
                services.AddSingleton(provider =>
                    provider.GetRequiredService<IOptions<ConfigurationOptions>>().Value);
                var role = configSection.GetValue<string>("WorkerRole");
                switch (role)
                {
                    case "sender":
                        services.AddTransient<IJob, MessageSender>();
                        break;
                    case "receiver":
                        services.AddTransient<IJob, MessageReceiver>();
                        break;
                    case "processor":
                        services.AddTransient<IJob, MessageProcessor>();
                        break;
                    default:
                        throw new ArgumentException(
                            "The role argument needs to be either sender, receiver or processor");
                }             
            });
}
