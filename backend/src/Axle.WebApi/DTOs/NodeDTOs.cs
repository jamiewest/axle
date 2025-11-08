using System.Text.Json;

namespace Axle.DTOs;

public record CreateNodeRequest(
    string Type,
    string Name,
    Guid? WorkspaceId = null,
    string? Subtype = null,
    Guid? ParentId = null,
    Dictionary<string, object>? Meta = null
);

public record UpdateNodeRequest(
    string Name,
    string Type,
    string? Subtype = null,
    Guid? ParentId = null,
    Dictionary<string, object>? Meta = null
);

public record NodeResponse(
    Guid Id,
    Guid TenantId,
    Guid? WorkspaceId,
    Guid? ParentId,
    string Type,
    string? Subtype,
    string Name,
    Dictionary<string, object>? Meta,
    DateTime CreatedAt,
    string CreatedById,
    string? CreatedByName,
    DateTime? ModifiedAt,
    string? ModifiedById,
    string? ModifiedByName
);

public record NodeListResponse(
    List<NodeResponse> Items,
    int TotalCount,
    int Page,
    int PageSize
);
