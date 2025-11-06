var builder = DistributedApplication.CreateBuilder(args);

var database = builder.AddSqlite("sqlite");

// Add migration service - runs migrations at startup
var migrations = builder.AddProject<Projects.Axle_MigrationService>("migrations")
    .WithReference(database);

// Add backend API project - waits for migrations to complete before starting
var backend = builder.AddProject<Projects.Axle>("webapi")
    .WithReference(database)
    .WaitForCompletion(migrations);

builder.Build().Run();
