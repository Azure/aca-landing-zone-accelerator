using aca_jobs.Model;
using Microsoft.Extensions.Options;

namespace aca_jobs;

public class Program
{
    public static void Main(string[] args)
    {
        Host.CreateDefaultBuilder(args)
            .ConfigureServices((hostcontext, services) =>
                {
                    services.AddLogging(logging =>
                    {
                        logging.ClearProviders();
                        logging.AddConfiguration(hostcontext.Configuration.GetSection("Logging"));
                        logging.AddConsole();
                    });
                    services.Configure<ConfigurationOptions>(hostcontext.Configuration.GetSection("settings"));
                    services.AddSingleton(provider =>
                        provider.GetRequiredService<IOptions<ConfigurationOptions>>().Value);
                    services.AddHostedService<BackroundJob>();
                })
            .Build()
            .Run();
    }
}
