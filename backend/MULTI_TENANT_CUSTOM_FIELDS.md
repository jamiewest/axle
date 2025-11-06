# Multi-Tenant Custom Fields System

## Overview

This system enables multi-tenancy with configurable custom fields per tenant. It allows tenants to define their own fields for different entity types, specify validation rules, and control how fields appear in the UI.

## Architecture

### Core Concepts

1. **Tenant** - An organization or workspace with isolated data
2. **WorkItem** - Generic entity that can represent anything (Task, Project, Customer, etc.)
3. **FieldDefinition** - Defines what custom fields can exist for a specific entity type
4. **Meta** - JSON column storing actual custom field values in WorkItem

```
┌─────────────────────┐
│   FieldDefinition   │ ──→ Defines field structure
│  (per tenant/type)  │     (name, type, validation, UI config)
└─────────────────────┘
           │
           │ maps to
           ↓
┌─────────────────────┐
│     WorkItem        │ ──→ Actual data
│  [meta JSON blob]   │     { "field_key": "value" }
└─────────────────────┘
```

## Database Schema

### Tenant
- `Id` (Guid) - Primary key
- `Name` (string) - Display name
- `Slug` (string, unique) - URL-friendly identifier
- `IsActive` (bool) - Whether tenant is active
- `Settings` (JSON) - Tenant-specific configuration
- `CreatedAt`, `UpdatedAt` (DateTime)

### TenantUser
- `Id` (Guid) - Primary key
- `TenantId` (FK) - Reference to tenant
- `UserId` (FK) - Reference to ApplicationUser
- `Role` (string) - Owner, Admin, Member, Viewer
- `JoinedAt` (DateTime)
- `IsActive` (bool)

**Unique constraint:** (TenantId, UserId)

### WorkItem
- `Id` (Guid) - Primary key
- `TenantId` (FK) - Tenant isolation
- `ParentId` (FK, nullable) - Hierarchical parent
- `Type` (string) - Entity type (Task, Project, etc.)
- `Subtype` (string, nullable) - Further categorization
- `Name` (string) - Display name
- `Meta` (JSON) - Custom field values
- `CreatedAt`, `ModifiedAt` (DateTime)
- `CreatedById`, `ModifiedById` (FK) - User references

**Indexes:**
- (TenantId, Type) - Query by tenant and type
- (TenantId, CreatedAt) - Recent items

**Example Meta JSON:**
```json
{
  "priority": "High",
  "due_date": "2024-12-31",
  "assignee_id": "user123",
  "status": "In Progress",
  "custom_tags": ["urgent", "backend"]
}
```

### FieldDefinition
- `Id` (Guid) - Primary key
- `TenantId` (FK) - Tenant isolation
- `EntityType` (string) - Which WorkItem type this field applies to
- `FieldName` (string) - Display name
- `FieldKey` (string) - Unique key for Meta JSON
- `FieldType` (string) - Data type (text, number, date, select, etc.)
- `DisplayOrder` (int) - Sort order in UI
- `IsRequired` (bool) - Validation flag
- `IsEnabled` (bool) - Soft delete flag
- `ValidationRules` (JSON) - Validation configuration
- `UiMetadata` (JSON) - UI configuration
- `CreatedAt`, `UpdatedAt` (DateTime)

**Unique constraint:** (TenantId, EntityType, FieldKey)

**Indexes:**
- (TenantId, EntityType) - Query fields for entity type
- (TenantId, EntityType, DisplayOrder) - Sorted field list

## Field Types

### Basic Types
- `text` - Single line text
- `textarea` - Multi-line text
- `number` - Integer
- `decimal` - Decimal number
- `boolean` - True/false checkbox
- `date` - Date only
- `datetime` - Date and time
- `time` - Time only

### Selection Types
- `select` - Dropdown (single choice)
- `multiselect` - Multiple choice
- `radio` - Radio buttons

### Advanced Types
- `email` - Email address
- `phone` - Phone number
- `url` - Web URL
- `file` - File upload
- `image` - Image upload
- `currency` - Money with currency code
- `percentage` - Percentage value

### Complex Types
- `json` - Arbitrary JSON data
- `relation` - Reference to another WorkItem
- `user` - Reference to a User

## Validation Rules

Example ValidationRules JSON:

```json
{
  "minLength": 3,
  "maxLength": 100,
  "pattern": "^[A-Z]",
  "min": 0,
  "max": 100,
  "options": [
    { "value": "low", "label": "Low" },
    { "value": "medium", "label": "Medium" },
    { "value": "high", "label": "High" }
  ],
  "maxFileSize": 5242880,
  "allowedFileTypes": [".pdf", ".docx"]
}
```

## UI Metadata

Example UiMetadata JSON:

```json
{
  "label": "Priority",
  "placeholder": "Select priority level",
  "helpText": "Task priority from low to critical",
  "icon": "flag",
  "showInList": true,
  "showInForm": true,
  "section": "Details",
  "width": 6
}
```

## API Endpoints

### Tenants

**GET /api/tenants** - List user's tenants
- Returns: `List<TenantResponse>`

**POST /api/tenants** - Create new tenant
- Body: `CreateTenantRequest`
- Returns: `TenantResponse`
- Note: Creator becomes Owner

**GET /api/tenants/{id}** - Get tenant by ID
- Returns: `TenantResponse`

### Work Items

**GET /api/work-items** - List work items (paginated)
- Query params: `page`, `pageSize`, `type`, `parentId`, `search`
- Returns: `WorkItemListResponse`

**GET /api/work-items/{id}** - Get single work item
- Returns: `WorkItemResponse`

**POST /api/work-items** - Create work item
- Body: `CreateWorkItemRequest`
- Returns: `WorkItemResponse`

**PUT /api/work-items/{id}** - Update work item
- Body: `UpdateWorkItemRequest`
- Returns: `WorkItemResponse`

**DELETE /api/work-items/{id}** - Delete work item
- Returns: 204 No Content

**GET /api/work-items/{id}/children** - Get child work items
- Returns: `List<WorkItemResponse>`

### Field Definitions

**GET /api/field-definitions** - List field definitions
- Query param: `entityType` (optional)
- Returns: `List<FieldDefinitionResponse>`

**GET /api/field-definitions/{id}** - Get field definition
- Returns: `FieldDefinitionResponse`

**POST /api/field-definitions** - Create field definition
- Body: `CreateFieldDefinitionRequest`
- Returns: `FieldDefinitionResponse`

**PUT /api/field-definitions/{id}** - Update field definition
- Body: `UpdateFieldDefinitionRequest`
- Returns: `FieldDefinitionResponse`

**DELETE /api/field-definitions/{id}** - Soft delete field
- Returns: 204 No Content
- Note: Sets IsEnabled = false

**POST /api/field-definitions/reorder** - Reorder fields
- Query param: `entityType`
- Body: `ReorderFieldsRequest` (list of field IDs in new order)
- Returns: Success message

**POST /api/field-definitions/{id}/validate** - Validate field value
- Body: `ValidateFieldValueRequest`
- Returns: `ValidateFieldValueResponse` (isValid, errors)

## Tenant Isolation

### Middleware
`TenantMiddleware` extracts tenant context from:

1. **X-Tenant-Id header** (priority 1)
2. **JWT claim "tenant_id"** (priority 2)
3. **Subdomain** (priority 3) - e.g., acme.example.com
4. **Route parameter** (priority 4) - e.g., /api/tenants/{tenantId}/...

The tenant ID is stored in `HttpContext.Items["TenantId"]` and used by:
- EF Core global query filters
- Services (WorkItemService, FieldDefinitionService)

### EF Core Query Filters

```csharp
// Automatically filters by current tenant
entity.HasQueryFilter(e =>
    CurrentTenantId == null ||
    e.TenantId == CurrentTenantId);
```

This ensures data isolation at the database level.

## Usage Example

### 1. Create a Tenant

```bash
POST /api/tenants
{
  "name": "Acme Corp",
  "slug": "acme",
  "settings": "{\"theme\": \"dark\"}"
}
```

### 2. Define Custom Fields for "Task" Entity

```bash
POST /api/field-definitions
{
  "entityType": "Task",
  "fieldName": "Priority",
  "fieldKey": "priority",
  "fieldType": "select",
  "displayOrder": 0,
  "isRequired": true,
  "validationRules": {
    "options": [
      { "value": "low", "label": "Low" },
      { "value": "high", "label": "High" }
    ]
  },
  "uiMetadata": {
    "label": "Priority",
    "helpText": "Task priority level"
  }
}
```

### 3. Create a Work Item with Custom Fields

```bash
POST /api/work-items
Header: X-Tenant-Id: <tenant-id>
{
  "type": "Task",
  "name": "Implement authentication",
  "meta": {
    "priority": "high",
    "due_date": "2024-12-31",
    "assignee": "john@example.com"
  }
}
```

### 4. Query Work Items

```bash
GET /api/work-items?type=Task&page=1&pageSize=20
Header: X-Tenant-Id: <tenant-id>
```

### 5. Build Dynamic Form (Frontend)

```typescript
// 1. Fetch field definitions
const fields = await fetch('/api/field-definitions?entityType=Task');

// 2. Render form based on field types
fields.forEach(field => {
  switch (field.fieldType) {
    case 'text':
      renderTextField(field);
      break;
    case 'select':
      renderSelectField(field, field.validationRules.options);
      break;
    // ... etc
  }
});

// 3. Validate on submit
const errors = await Promise.all(
  fields.map(field =>
    fetch(`/api/field-definitions/${field.id}/validate`, {
      body: JSON.stringify({ value: formData[field.fieldKey] })
    })
  )
);
```

## Services

### IWorkItemService
- `GetByIdAsync(id)` - Get single item
- `GetAllAsync(type, parentId)` - Get all items
- `GetPagedAsync(...)` - Paginated query
- `CreateAsync(workItem)` - Create item
- `UpdateAsync(id, workItem)` - Update item
- `DeleteAsync(id)` - Delete item
- `GetChildrenAsync(parentId)` - Get children
- `GetAncestorsAsync(id)` - Get ancestor path

### IFieldDefinitionService
- `GetByIdAsync(id)` - Get single definition
- `GetByEntityTypeAsync(entityType)` - Get fields for entity
- `GetAllAsync()` - Get all fields
- `CreateAsync(fieldDefinition)` - Create field
- `UpdateAsync(id, fieldDefinition)` - Update field
- `DeleteAsync(id)` - Soft delete field
- `ReorderAsync(entityType, fieldIds)` - Reorder fields
- `ValidateFieldValueAsync(fieldId, value)` - Validate value

## Best Practices

### Field Keys
- Use lowercase with underscores: `due_date`, `assignee_id`
- Make them descriptive: `customer_contact_email` vs `email`
- Never change field keys after creation (breaks existing data)

### Field Types
- Choose the most specific type (use `email` instead of `text`)
- Use `relation` for references to other WorkItems
- Use `user` for references to users

### Validation
- Always validate on both client and server
- Use `isRequired` for mandatory fields
- Provide clear error messages in validation rules

### UI Metadata
- Always provide labels and help text
- Use sections to group related fields
- Set appropriate widths (1-12 grid system)

### Performance
- Index frequently queried Meta fields using JSON functions
- Paginate large lists
- Cache field definitions (they rarely change)

### Hierarchies
- Use `parentId` for tree structures
- Limit depth to avoid performance issues
- Consider breadcrumbs using `GetAncestorsAsync`

## Migration Strategy

If migrating from single-tenant:

1. Create a default tenant
2. Migrate existing users to default tenant as Owners
3. Migrate existing entities to WorkItems with Type
4. Extract common fields into FieldDefinitions
5. Move data to Meta JSON column
6. Test thoroughly before removing old tables

## Next Steps

### Backend
- [ ] Add field-level permissions (who can view/edit each field)
- [ ] Add calculated fields (auto-compute from other fields)
- [ ] Add field templates (predefined field sets)
- [ ] Add field value history/audit trail
- [ ] Add bulk import/export with custom fields

### Frontend
- [ ] Build dynamic form generator component
- [ ] Add drag-and-drop field reordering
- [ ] Build field definition manager UI
- [ ] Add field validation feedback
- [ ] Create field type library (reusable widgets)

### Testing
- [ ] Unit tests for validation logic
- [ ] Integration tests for tenant isolation
- [ ] Performance tests for large JSON queries
- [ ] End-to-end tests for form workflows

## Troubleshooting

**Q: WorkItems not showing up**
- Check tenant context in request (X-Tenant-Id header or JWT claim)
- Verify tenant is active
- Check user is member of tenant

**Q: Field validation not working**
- Verify ValidationRules JSON is valid
- Check field type matches validation rules
- Test with `/api/field-definitions/{id}/validate` endpoint

**Q: Performance issues with large Meta**
- Create SQLite JSON indexes on frequently queried fields
- Limit Meta to reasonable size (< 64KB per item)
- Consider moving large data to separate file storage

**Q: Tenant isolation broken**
- Verify TenantMiddleware is registered after authentication
- Check EF Core query filters are configured
- Review CurrentTenantId extraction logic
