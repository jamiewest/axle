using Axle.Models;

namespace Axle.Services;

/// <summary>
/// Service for managing field definitions with tenant isolation.
/// </summary>
public interface IFieldDefinitionService
{
    /// <summary>
    /// Gets a field definition by ID (tenant-scoped).
    /// </summary>
    Task<FieldDefinition?> GetByIdAsync(Guid id);

    /// <summary>
    /// Gets all field definitions for an entity type in the current tenant.
    /// </summary>
    Task<List<FieldDefinition>> GetByEntityTypeAsync(string entityType);

    /// <summary>
    /// Gets all field definitions for the current tenant.
    /// </summary>
    Task<List<FieldDefinition>> GetAllAsync();

    /// <summary>
    /// Creates a new field definition.
    /// </summary>
    Task<FieldDefinition> CreateAsync(FieldDefinition fieldDefinition);

    /// <summary>
    /// Updates an existing field definition.
    /// </summary>
    Task<FieldDefinition?> UpdateAsync(Guid id, FieldDefinition fieldDefinition);

    /// <summary>
    /// Deletes (soft delete by setting IsEnabled = false) a field definition.
    /// </summary>
    Task<bool> DeleteAsync(Guid id);

    /// <summary>
    /// Reorders field definitions for an entity type.
    /// </summary>
    Task ReorderAsync(string entityType, List<Guid> fieldIds);

    /// <summary>
    /// Validates field value against field definition rules.
    /// </summary>
    Task<(bool IsValid, List<string> Errors)> ValidateFieldValueAsync(
        Guid fieldDefinitionId,
        object? value);
}
