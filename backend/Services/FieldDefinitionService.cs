using System.Text.Json;
using System.Text.RegularExpressions;
using Axle.Data;
using Axle.Models;
using Microsoft.EntityFrameworkCore;

namespace Axle.Services;

/// <summary>
/// Implementation of IFieldDefinitionService for managing field definitions.
/// </summary>
public class FieldDefinitionService : IFieldDefinitionService
{
    private readonly ApplicationDbContext _context;
    private readonly IHttpContextAccessor _httpContextAccessor;
    private readonly ILogger<FieldDefinitionService> _logger;

    public FieldDefinitionService(
        ApplicationDbContext context,
        IHttpContextAccessor httpContextAccessor,
        ILogger<FieldDefinitionService> logger)
    {
        _context = context;
        _httpContextAccessor = httpContextAccessor;
        _logger = logger;
    }

    private Guid CurrentTenantId =>
        _httpContextAccessor.HttpContext?.Items["TenantId"] as Guid?
        ?? throw new InvalidOperationException("Tenant context not available");

    public async Task<FieldDefinition?> GetByIdAsync(Guid id)
    {
        return await _context.FieldDefinitions
            .FirstOrDefaultAsync(f => f.Id == id);
    }

    public async Task<List<FieldDefinition>> GetByEntityTypeAsync(string entityType)
    {
        return await _context.FieldDefinitions
            .Where(f => f.EntityType == entityType && f.IsEnabled)
            .OrderBy(f => f.DisplayOrder)
            .ToListAsync();
    }

    public async Task<List<FieldDefinition>> GetAllAsync()
    {
        return await _context.FieldDefinitions
            .Where(f => f.IsEnabled)
            .OrderBy(f => f.EntityType)
            .ThenBy(f => f.DisplayOrder)
            .ToListAsync();
    }

    public async Task<FieldDefinition> CreateAsync(FieldDefinition fieldDefinition)
    {
        fieldDefinition.TenantId = CurrentTenantId;
        fieldDefinition.CreatedAt = DateTime.UtcNow;

        // Validate field key uniqueness within tenant + entity type
        var exists = await _context.FieldDefinitions
            .AnyAsync(f =>
                f.TenantId == CurrentTenantId &&
                f.EntityType == fieldDefinition.EntityType &&
                f.FieldKey == fieldDefinition.FieldKey);

        if (exists)
        {
            throw new InvalidOperationException(
                $"Field key '{fieldDefinition.FieldKey}' already exists for entity type '{fieldDefinition.EntityType}'");
        }

        _context.FieldDefinitions.Add(fieldDefinition);
        await _context.SaveChangesAsync();

        _logger.LogInformation("Created field definition {Id} with key '{FieldKey}' for entity '{EntityType}' in tenant {TenantId}",
            fieldDefinition.Id, fieldDefinition.FieldKey, fieldDefinition.EntityType, fieldDefinition.TenantId);

        return fieldDefinition;
    }

    public async Task<FieldDefinition?> UpdateAsync(Guid id, FieldDefinition fieldDefinition)
    {
        var existing = await _context.FieldDefinitions.FindAsync(id);
        if (existing == null)
        {
            return null;
        }

        // Validate field key uniqueness if changed
        if (existing.FieldKey != fieldDefinition.FieldKey)
        {
            var keyExists = await _context.FieldDefinitions
                .AnyAsync(f =>
                    f.Id != id &&
                    f.TenantId == CurrentTenantId &&
                    f.EntityType == fieldDefinition.EntityType &&
                    f.FieldKey == fieldDefinition.FieldKey);

            if (keyExists)
            {
                throw new InvalidOperationException(
                    $"Field key '{fieldDefinition.FieldKey}' already exists for entity type '{fieldDefinition.EntityType}'");
            }
        }

        // Update fields
        existing.FieldName = fieldDefinition.FieldName;
        existing.FieldKey = fieldDefinition.FieldKey;
        existing.FieldType = fieldDefinition.FieldType;
        existing.DisplayOrder = fieldDefinition.DisplayOrder;
        existing.IsRequired = fieldDefinition.IsRequired;
        existing.IsEnabled = fieldDefinition.IsEnabled;
        existing.ValidationRules = fieldDefinition.ValidationRules;
        existing.UiMetadata = fieldDefinition.UiMetadata;
        existing.UpdatedAt = DateTime.UtcNow;

        await _context.SaveChangesAsync();

        _logger.LogInformation("Updated field definition {Id} in tenant {TenantId}",
            id, existing.TenantId);

        return existing;
    }

    public async Task<bool> DeleteAsync(Guid id)
    {
        var fieldDefinition = await _context.FieldDefinitions.FindAsync(id);
        if (fieldDefinition == null)
        {
            return false;
        }

        // Soft delete: set IsEnabled to false
        fieldDefinition.IsEnabled = false;
        fieldDefinition.UpdatedAt = DateTime.UtcNow;

        await _context.SaveChangesAsync();

        _logger.LogInformation("Soft-deleted field definition {Id} in tenant {TenantId}",
            id, fieldDefinition.TenantId);

        return true;
    }

    public async Task ReorderAsync(string entityType, List<Guid> fieldIds)
    {
        var fields = await _context.FieldDefinitions
            .Where(f => f.EntityType == entityType)
            .ToListAsync();

        for (int i = 0; i < fieldIds.Count; i++)
        {
            var field = fields.FirstOrDefault(f => f.Id == fieldIds[i]);
            if (field != null)
            {
                field.DisplayOrder = i;
                field.UpdatedAt = DateTime.UtcNow;
            }
        }

        await _context.SaveChangesAsync();

        _logger.LogInformation("Reordered {Count} field definitions for entity type '{EntityType}' in tenant {TenantId}",
            fieldIds.Count, entityType, CurrentTenantId);
    }

    public async Task<(bool IsValid, List<string> Errors)> ValidateFieldValueAsync(
        Guid fieldDefinitionId,
        object? value)
    {
        var field = await GetByIdAsync(fieldDefinitionId);
        if (field == null)
        {
            return (false, new List<string> { "Field definition not found" });
        }

        var errors = new List<string>();

        // Check required
        if (field.IsRequired && (value == null || string.IsNullOrWhiteSpace(value.ToString())))
        {
            errors.Add($"{field.FieldName} is required");
        }

        // Skip further validation if value is null and not required
        if (value == null)
        {
            return (errors.Count == 0, errors);
        }

        var valueStr = value.ToString() ?? string.Empty;

        // Parse validation rules if present
        if (!string.IsNullOrEmpty(field.ValidationRules))
        {
            try
            {
                var rules = JsonSerializer.Deserialize<Dictionary<string, JsonElement>>(field.ValidationRules);

                if (rules != null)
                {
                    // Text length validation
                    if (rules.TryGetValue("minLength", out var minLength) && valueStr.Length < minLength.GetInt32())
                    {
                        errors.Add($"{field.FieldName} must be at least {minLength.GetInt32()} characters");
                    }

                    if (rules.TryGetValue("maxLength", out var maxLength) && valueStr.Length > maxLength.GetInt32())
                    {
                        errors.Add($"{field.FieldName} must not exceed {maxLength.GetInt32()} characters");
                    }

                    // Pattern validation
                    if (rules.TryGetValue("pattern", out var pattern))
                    {
                        var regex = new Regex(pattern.GetString() ?? string.Empty);
                        if (!regex.IsMatch(valueStr))
                        {
                            errors.Add($"{field.FieldName} format is invalid");
                        }
                    }

                    // Number range validation
                    if (field.FieldType == FieldTypes.Number || field.FieldType == FieldTypes.Decimal)
                    {
                        if (decimal.TryParse(valueStr, out var numValue))
                        {
                            if (rules.TryGetValue("min", out var min) && numValue < min.GetDecimal())
                            {
                                errors.Add($"{field.FieldName} must be at least {min.GetDecimal()}");
                            }

                            if (rules.TryGetValue("max", out var max) && numValue > max.GetDecimal())
                            {
                                errors.Add($"{field.FieldName} must not exceed {max.GetDecimal()}");
                            }
                        }
                        else
                        {
                            errors.Add($"{field.FieldName} must be a valid number");
                        }
                    }

                    // Select options validation
                    if (field.FieldType == FieldTypes.Select && rules.TryGetValue("options", out var options))
                    {
                        var validOptions = options.EnumerateArray()
                            .Select(o => o.GetProperty("value").GetString())
                            .ToList();

                        if (!validOptions.Contains(valueStr))
                        {
                            errors.Add($"{field.FieldName} must be one of the valid options");
                        }
                    }
                }
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Error parsing validation rules for field {FieldId}", fieldDefinitionId);
                errors.Add("Validation error occurred");
            }
        }

        return (errors.Count == 0, errors);
    }
}
