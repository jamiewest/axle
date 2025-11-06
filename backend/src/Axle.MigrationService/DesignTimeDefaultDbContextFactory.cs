// using System;
// using System.IO;
// using Axle.Data;
// using Microsoft.EntityFrameworkCore;
// using Microsoft.EntityFrameworkCore.Design;
// using Microsoft.Extensions.Configuration;

// namespace DatabaseMigrations.MigrationService;

// /// <summary>
// /// Provides a design-time factory so dotnet-ef can create <see cref="DefaultDbContext"/> without running the hosted service.
// /// </summary>
// public class DesignTimeDefaultDbContextFactory : IDesignTimeDbContextFactory<ApplicationDbContext>
// {
//     public ApplicationDbContext CreateDbContext(string[] args)
//     {
//         var environment = Environment.GetEnvironmentVariable("ASPNETCORE_ENVIRONMENT") ?? "Development";

//         var basePath = Directory.GetCurrentDirectory();
//         if (!File.Exists(Path.Combine(basePath, "appsettings.json")))
//         {
//             var candidate = Path.Combine(basePath, "AspireDefault.MigrationService");
//             if (File.Exists(Path.Combine(candidate, "appsettings.json")))
//             {
//                 basePath = candidate;
//             }
//         }

//         var configuration = new ConfigurationBuilder()
//             .SetBasePath(basePath)
//             .AddJsonFile("appsettings.json", optional: true)
//             .AddJsonFile($"appsettings.{environment}.json", optional: true)
//             .AddEnvironmentVariables()
//             .Build();

//         var connectionString = configuration.GetConnectionString("appdb");
//         if (string.IsNullOrWhiteSpace(connectionString))
//         {
//             connectionString = Environment.GetEnvironmentVariable("EFCORE_CONNECTIONSTRING")
//                 ?? "Server=localhost;Database=AspireDefault;User Id=sa;Password=Your_password123;TrustServerCertificate=True;";
//         }

//         var options = new DbContextOptionsBuilder<ApplicationDbContext>();
//         options.UseSqlite(connectionString, sqlOptions =>
//             sqlOptions.MigrationsAssembly(typeof(DesignTimeDefaultDbContextFactory).Assembly.GetName().Name));

//         return new ApplicationDbContext(options.Options);
//     }
// }
