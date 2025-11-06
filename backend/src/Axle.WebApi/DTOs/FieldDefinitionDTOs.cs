using System.Text.Json;

namespace Axle.DTOs;

public record CreateFieldDefinitionRequest(
    string EntityType,
    string FieldName,
    string FieldKey,
    string FieldType,
    int DisplayOrder = 0,
    bool IsRequired = false,
    bool IsEnabled = true,
    Dictionary<string, object>? ValidationRules = null,
    Dictionary<string, object>? UiMetadata = null
);

public record UpdateFieldDefinitionRequest(
    string FieldName,
    string FieldKey,
    string FieldType,
    int DisplayOrder = 0,
    bool IsRequired = false,
    bool IsEnabled = true,
    Dictionary<string, object>? ValidationRules = null,
    Dictionary<string, object>? UiMetadata = null
);

public record FieldDefinitionResponse(
    Guid Id,
    Guid TenantId,
    string EntityType,
    string FieldName,
    string FieldKey,
    string FieldType,
    int DisplayOrder,
    bool IsRequired,
    bool IsEnabled,
    Dictionary<string, object>? ValidationRules,
    Dictionary<string, object>? UiMetadata,
    DateTime CreatedAt,
    DateTime? UpdatedAt
);

public record ReorderFieldsRequest(
    List<Guid> FieldIds
);

public record ValidateFieldValueRequest(
    object? Value
);

public record ValidateFieldValueResponse(
    bool IsValid,
    List<string> Errors
);
