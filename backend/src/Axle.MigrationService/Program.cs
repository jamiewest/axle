using Axle.Data;
using Axle.MigrationService;
using Axle.ServiceDefaults;
using Microsoft.EntityFrameworkCore;

var builder = Host.CreateApplicationBuilder(args);

builder.AddServiceDefaults();
builder.Services.AddHostedService<Worker>();
builder.Services.AddOpenTelemetry()
    .WithTracing(tracing => tracing.AddSource(Worker.ActivitySourceName));

builder.AddSqliteDbContext<ApplicationDbContext>(name: "sqlite");

var host = builder.Build();
host.Run();
