namespace aca_jobs.Model;

public class ConfigurationOptions
{
    public string? WorkerRole { get; set; }
    public string? ServiceBusNamespace { get; set; }
    public string? InputQueueName { get; set; }
    public string? OutputQueueName { get; set; }

    public int MinNumber { get; set; } = 1;
    public int MaxNumber { get; set; } = 10;
    public int MessageCount { get; set; } = 10;
    public int FetchCount { get; set; } = 10;
    public int MaxWaitTime { get; set; } = 1;
    public string SendType { get; set; } = "list";
}