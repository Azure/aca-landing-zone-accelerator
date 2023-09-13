namespace aca_jobs;

public interface IJob
{
    Task ExecuteAsync(CancellationToken stoppingToken);
}