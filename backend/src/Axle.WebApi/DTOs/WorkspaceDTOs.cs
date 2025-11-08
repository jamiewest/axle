namespace Axle.DTOs;

public record CreateWorkspaceRequest(
    Guid TenantId,
    string Name,
    string? Description = null
);

public record UpdateWorkspaceRequest(
    string Name,
    string? Description = null,
    bool? IsActive = null
);

public record WorkspaceResponse(
    Guid Id,
    Guid TenantId,
    string Name,
    string? Description,
    bool IsActive,
    DateTime CreatedAt,
    string CreatedById,
    string? CreatedByName,
    DateTime? UpdatedAt,
    string? UpdatedById,
    string? UpdatedByName
);

public record WorkspaceListResponse(
    List<WorkspaceResponse> Items,
    int TotalCount,
    int Page,
    int PageSize
);
