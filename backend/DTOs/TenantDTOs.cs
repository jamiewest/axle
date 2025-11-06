namespace Axle.DTOs;

public record CreateTenantRequest(
    string Name,
    string Slug,
    string? Settings = null
);

public record UpdateTenantRequest(
    string Name,
    bool IsActive,
    string? Settings = null
);

public record TenantResponse(
    Guid Id,
    string Name,
    string Slug,
    bool IsActive,
    string? Settings,
    DateTime CreatedAt,
    DateTime? UpdatedAt
);

public record TenantUserResponse(
    Guid Id,
    Guid TenantId,
    string TenantName,
    string UserId,
    string UserEmail,
    string Role,
    DateTime JoinedAt,
    bool IsActive
);

public record AddUserToTenantRequest(
    string UserEmail,
    string Role = "Member"
);
