// using System.Diagnostics;
// using Microsoft.Data.SqlClient;
// using Microsoft.EntityFrameworkCore;
// using Microsoft.EntityFrameworkCore.Infrastructure;
// using Microsoft.EntityFrameworkCore.Storage;
// using Microsoft.Extensions.DependencyInjection;
// using Microsoft.Extensions.Logging;
// using OpenTelemetry.Trace;

// namespace DatabaseMigrations.MigrationService;

// public class DatabaseInitializer(
//     IServiceProvider serviceProvider,
//     IHostEnvironment hostEnvironment,
//     IHostApplicationLifetime hostApplicationLifetime,
//     ILogger<DatabaseInitializer> logger) : BackgroundService
// {
//     private readonly ActivitySource _activitySource = new(hostEnvironment.ApplicationName);
//     private readonly ILogger<DatabaseInitializer> _logger = logger;

//     protected override async Task ExecuteAsync(CancellationToken cancellationToken)
//     {
//         using var activity = _activitySource.StartActivity(hostEnvironment.ApplicationName, ActivityKind.Client);
//         _logger.LogInformation("Database initialization starting in {Environment}", hostEnvironment.EnvironmentName);

//         try
//         {
//             using var scope = serviceProvider.CreateScope();
//             var dbContext = scope.ServiceProvider.GetRequiredService<DefaultDbContext>();

//             await EnsureDatabaseAsync(dbContext, cancellationToken);
//             await RunMigrationAsync(dbContext, cancellationToken);

//             _logger.LogInformation("Database initialization completed successfully");
//         }
//         catch (SqlException sqlEx)
//         {
//             _logger.LogError(sqlEx, "Database initialization failed due to SQL error: {Message}", sqlEx.Message);
//             activity?.AddException(sqlEx);
//             throw;
//         }
//         catch (Exception ex)
//         {
//             _logger.LogError(ex, "Database initialization failed: {Message}", ex.Message);
//             activity?.AddException(ex);
//             throw;
//         }
//         finally
//         {
//             hostApplicationLifetime.StopApplication();
//         }
//     }

//     private async Task EnsureDatabaseAsync(DefaultDbContext dbContext, CancellationToken cancellationToken)
//     {
//         _logger.LogInformation("Ensuring database exists for provider {Provider}", dbContext.Database.ProviderName);
//         var dbCreator = dbContext.GetService<IRelationalDatabaseCreator>();

//         var strategy = dbContext.Database.CreateExecutionStrategy();
//         await strategy.ExecuteAsync(async () =>
//         {
//             if (!await dbCreator.ExistsAsync(cancellationToken))
//             {
//                 _logger.LogInformation("Database not found; creating new database");
//                 await dbCreator.CreateAsync(cancellationToken);
//             }
//             else
//             {
//                 _logger.LogDebug("Database already present; skipping creation");
//             }
//         });
//     }

//     private async Task RunMigrationAsync(DefaultDbContext dbContext, CancellationToken cancellationToken)
//     {
//         _logger.LogInformation("Applying EF Core migrations");
//         var strategy = dbContext.Database.CreateExecutionStrategy();
//         await strategy.ExecuteAsync(async () =>
//         {
//             await using var transaction = await dbContext.Database.BeginTransactionAsync(cancellationToken);
//             await dbContext.Database.MigrateAsync(cancellationToken);
//             await transaction.CommitAsync(cancellationToken);
//             _logger.LogInformation("EF Core migrations applied successfully");
//         });
//     }
// }
