var builder = DistributedApplication.CreateBuilder(args);

// Add SQLite database connection string
var database = builder.AddConnectionString("sqldata", "Data Source=../Axle.WebApi/axle.db");

// Add migration service - runs migrations at startup
var migrations = builder.AddProject<Projects.Axle_MigrationService>("migrations")
    .WithReference(database);

// Add backend API project - waits for migrations to complete before starting
var backend = builder.AddProject<Projects.Axle>("backend")
    .WithReference(database)
    .WaitForCompletion(migrations);

builder.Build().Run();
