using Serilog;
using Serilog.Formatting.Compact;

var builder = WebApplication.CreateBuilder(args);

builder.Host.UseSerilog((context, config) =>
{
    config.ReadFrom.Configuration(context.Configuration)
        .Enrich.FromLogContext()
        .WriteTo.Console(new CompactJsonFormatter());
});

builder.Services.AddOpenApi();

var app = builder.Build();

var appName = app.Configuration["App:Name"] ?? "catalog-api";
var environment = app.Configuration["App:Environment"] ?? "local-dev";

if (app.Environment.IsDevelopment())
{
    app.MapOpenApi();
}

app.UseHttpsRedirection();
app.UseRouting();

// Log każdego uderzenia w endpoint — rozróżnialne od logów systemowych (LogSource + EventType)
app.Use(async (context, next) =>
{
    await next();
    var endpoint = context.GetEndpoint();
    var logger = Log.ForContext("LogSource", "Application")
        .ForContext("EventType", "EndpointHit");
    logger.Information(
        "Endpoint hit: {Method} {Path} -> {EndpointName}, StatusCode: {StatusCode}",
        context.Request.Method,
        context.Request.Path,
        endpoint?.DisplayName ?? "(none)",
        context.Response.StatusCode);
});

app.MapGet("/", () => Results.Ok(new { service = appName, environment, status = "ok" }))
    .WithName("Root");

app.MapGet("/api/catalog", () => Results.Ok(Array.Empty<object>()))
    .WithName("GetCatalog");

app.MapGet("/health", () => Results.Ok(new { status = "Healthy", service = appName, environment }))
    .WithName("Health");

try
{
    app.Run();
}
finally
{
    Log.CloseAndFlush();
}
