using System.ComponentModel.DataAnnotations;

namespace Axle.Models;

/// <summary>
/// Defines a custom field that can be used in Node metadata.
/// Each tenant can define their own fields per entity type.
/// </summary>
public class FieldDefinition
{
    /// <summary>
    /// Unique identifier for the field definition.
    /// </summary>
    public Guid Id { get; set; } = Guid.NewGuid();

    /// <summary>
    /// Tenant this field definition belongs to.
    /// </summary>
    public Guid TenantId { get; set; }

    /// <summary>
    /// Navigation property to tenant.
    /// </summary>
    public Tenant Tenant { get; set; } = null!;

    /// <summary>
    /// Entity type this field applies to (e.g., "Task", "Project", "Customer").
    /// Must match Node.Type.
    /// </summary>
    [Required]
    [MaxLength(100)]
    public string EntityType { get; set; } = string.Empty;

    /// <summary>
    /// Display name of the field shown in the UI.
    /// </summary>
    [Required]
    [MaxLength(200)]
    public string FieldName { get; set; } = string.Empty;

    /// <summary>
    /// Unique key for this field within the tenant and entity type.
    /// Used as the key in Node.Meta JSON.
    /// Example: "priority", "due_date", "custom_status"
    /// </summary>
    [Required]
    [MaxLength(100)]
    public string FieldKey { get; set; } = string.Empty;

    /// <summary>
    /// Data type of the field.
    /// </summary>
    [Required]
    [MaxLength(50)]
    public string FieldType { get; set; } = FieldTypes.Text;

    /// <summary>
    /// Order in which this field appears in forms and lists.
    /// Lower numbers appear first.
    /// </summary>
    public int DisplayOrder { get; set; } = 0;

    /// <summary>
    /// Whether this field is required (must have a value).
    /// </summary>
    public bool IsRequired { get; set; } = false;

    /// <summary>
    /// Whether this field is currently enabled and visible.
    /// </summary>
    public bool IsEnabled { get; set; } = true;

    /// <summary>
    /// JSON blob containing validation rules (min, max, pattern, options, etc.).
    /// Example: { "min": 0, "max": 100, "pattern": "^[A-Z]", "options": [...] }
    /// </summary>
    public string? ValidationRules { get; set; }

    /// <summary>
    /// JSON blob containing UI-specific metadata (label, placeholder, help text, etc.).
    /// Example: { "label": "Priority", "placeholder": "Select priority", "helpText": "Task priority level" }
    /// </summary>
    public string? UiMetadata { get; set; }

    /// <summary>
    /// When the field definition was created.
    /// </summary>
    public DateTime CreatedAt { get; set; } = DateTime.UtcNow;

    /// <summary>
    /// When the field definition was last updated.
    /// </summary>
    public DateTime? UpdatedAt { get; set; }
}

/// <summary>
/// Supported field types.
/// </summary>
public static class FieldTypes
{
    // Basic types
    public const string Text = "text";
    public const string TextArea = "textarea";
    public const string Number = "number";
    public const string Decimal = "decimal";
    public const string Boolean = "boolean";
    public const string Date = "date";
    public const string DateTime = "datetime";
    public const string Time = "time";

    // Selection types
    public const string Select = "select";
    public const string MultiSelect = "multiselect";
    public const string Radio = "radio";

    // Advanced types
    public const string Email = "email";
    public const string Phone = "phone";
    public const string Url = "url";
    public const string File = "file";
    public const string Image = "image";
    public const string Currency = "currency";
    public const string Percentage = "percentage";

    // Complex types
    public const string Json = "json";
    public const string Relation = "relation";  // References another Node
    public const string User = "user";          // References a User
}
