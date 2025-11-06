using System.Text.Json;

namespace Axle.DTOs;

public record CreateWorkItemRequest(
    string Type,
    string Name,
    string? Subtype = null,
    Guid? ParentId = null,
    Dictionary<string, object>? Meta = null
);

public record UpdateWorkItemRequest(
    string Name,
    string Type,
    string? Subtype = null,
    Guid? ParentId = null,
    Dictionary<string, object>? Meta = null
);

public record WorkItemResponse(
    Guid Id,
    Guid TenantId,
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

public record WorkItemListResponse(
    List<WorkItemResponse> Items,
    int TotalCount,
    int Page,
    int PageSize
);
