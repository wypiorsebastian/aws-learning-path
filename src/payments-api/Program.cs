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

var appName = app.Configuration["App:Name"] ?? "payments-api";
var environment = app.Configuration["App:Environment"] ?? "local-dev";

if (app.Environment.IsDevelopment())
{
    app.MapOpenApi();
}

app.UseHttpsRedirection();

app.MapGet("/", () => Results.Ok(new { service = appName, environment, status = "ok" }))
    .WithName("Root");

app.MapGet("/api/payments", () => Results.Ok(Array.Empty<object>()))
    .WithName("GetPayments");

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
