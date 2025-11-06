using Axle.Data;
using Axle.MigrationService;
using Axle.ServiceDefaults;
using Microsoft.EntityFrameworkCore;

var builder = Host.CreateApplicationBuilder(args);

builder.AddServiceDefaults();
builder.Services.AddHostedService<Worker>();
builder.Services.AddOpenTelemetry()
    .WithTracing(tracing => tracing.AddSource(Worker.ActivitySourceName));

// Add the DbContext with SQLite
builder.Services.AddDbContext<ApplicationDbContext>(options =>
{
    var connectionString = builder.Configuration.GetConnectionString("sqldata")
        ?? "Data Source=axle.db";
    options.UseSqlite(connectionString);
});

var host = builder.Build();
host.Run();
