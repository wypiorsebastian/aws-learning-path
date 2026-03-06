namespace OrderWorker;

public sealed class OrderWorkerService : BackgroundService
{
    private readonly ILogger<OrderWorkerService> _logger;
    private readonly IConfiguration _configuration;
    private static readonly TimeSpan Interval = TimeSpan.FromSeconds(15);

    public OrderWorkerService(ILogger<OrderWorkerService> logger, IConfiguration configuration)
    {
        _logger = logger;
        _configuration = configuration;
    }

    public override async Task StopAsync(CancellationToken cancellationToken)
    {
        _logger.LogInformation("Shutdown requested, stopping order worker...");
        await base.StopAsync(cancellationToken);
    }

    protected override async Task ExecuteAsync(CancellationToken stoppingToken)
    {
        var appName = _configuration["App:Name"] ?? "order-worker";
        var environment = _configuration["App:Environment"] ?? "local-dev";

        _logger.LogInformation("Order worker started. Service: {Service}, Environment: {Environment}", appName, environment);

        try
        {
            while (!stoppingToken.IsCancellationRequested)
            {
                _logger.LogInformation("Order worker running at {Time:O}", DateTimeOffset.UtcNow);
                await Task.Delay(Interval, stoppingToken);
            }
        }
        finally
        {
            _logger.LogInformation("Order worker stopped gracefully.");
        }
    }
}
