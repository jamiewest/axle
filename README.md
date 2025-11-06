# Axle

A full-stack multi-tenant project management application built with .NET 9 and Flutter.

## Overview

Axle is a modern, cloud-native application that provides project management capabilities with multi-tenant support. It features a robust backend API built with ASP.NET Core and a cross-platform frontend built with Flutter.

## Architecture

### Backend (.NET 9)

The backend is built using .NET Aspire for cloud-native orchestration and follows Microsoft best practices:

- **Axle.AppHost** - Aspire orchestration host that manages service startup and dependencies
- **Axle.WebApi** - Main REST API with ASP.NET Core Identity authentication
- **Axle.MigrationService** - Automated database migration service that runs at startup
- **Axle.ServiceDefaults** - Shared configuration for OpenTelemetry, health checks, and service discovery

**Key Features:**
- Multi-tenant architecture with tenant isolation
- ASP.NET Core Identity for authentication and authorization
- Entity Framework Core with SQLite database
- gRPC support for real-time updates
- Automatic database migrations via Aspire orchestration
- OpenTelemetry for distributed tracing and observability

### Frontend (Flutter)

Cross-platform mobile and web application located in `frontend/flutter/`:

- Supports iOS, Android, Web, macOS, Windows, and Linux
- Authentication flow with account creation, email confirmation, and password reset
- gRPC integration for real-time updates
- Clean architecture with separation of concerns (data, domain, presentation layers)

## Project Structure

```
axle/
├── backend/
│   ├── Axle.sln                    # Solution file
│   └── src/
│       ├── Axle.AppHost/           # Aspire orchestration
│       ├── Axle.ServiceDefaults/   # Shared configuration
│       ├── Axle.WebApi/            # REST API
│       └── Axle.MigrationService/  # Database migrations
├── frontend/
│   └── flutter/                    # Flutter application
├── docs/                           # Documentation
└── .vscode/                        # VS Code configurations
```

## Getting Started

### Prerequisites

- .NET 9 SDK
- Flutter SDK (for frontend development)
- Git

### Running the Application

#### Using VS Code

The project includes launch configurations for easy development:

1. **Full Stack (Aspire + Frontend)** - Runs both backend (via Aspire) and Flutter app
2. **Full Stack (Standalone + Frontend)** - Runs backend without Aspire and Flutter app
3. **Aspire: AppHost** - Runs only the backend via Aspire orchestration
4. **Backend: WebApi (Standalone)** - Runs only the backend API
5. **Frontend: Flutter** - Runs only the Flutter app

#### Command Line

**Backend with Aspire:**
```bash
cd backend/src/Axle.AppHost
dotnet run
```

**Backend Standalone:**
```bash
cd backend/src/Axle.WebApi
dotnet run
```

**Frontend:**
```bash
cd frontend/flutter
flutter run
```

### Database Migrations

Migrations are handled automatically by the Aspire orchestration when running via AppHost. The MigrationService runs database migrations before the WebApi starts.

For manual migration management:
```bash
cd backend/src/Axle.WebApi
dotnet ef migrations add MigrationName
dotnet ef database update
```

## Multi-Tenancy

Axle supports multi-tenancy with tenant isolation at the data level. Each user belongs to one or more tenants, and data is filtered based on the current tenant context set via middleware.

## API Documentation

When running in development mode, the API includes:
- Swagger UI available at `/swagger`
- Health checks at `/health` and `/alive`
- OpenTelemetry endpoints for observability

## Contributing

This is a private project. Please contact the repository owner for contribution guidelines.

## License

All rights reserved.
