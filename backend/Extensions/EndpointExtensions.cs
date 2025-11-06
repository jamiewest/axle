using System.Text.Json;
using Axle.Data;
using Axle.DTOs;
using Axle.Models;
using Axle.Services;
using Microsoft.AspNetCore.Identity;
using Microsoft.EntityFrameworkCore;

namespace Axle.Extensions;

public static class EndpointExtensions
{
    public static WebApplication MapTenantEndpoints(this WebApplication app)
    {
        var tenants = app.MapGroup("/api/tenants").RequireAuthorization();

        // GET /api/tenants - List all tenants for current user
        tenants.MapGet("/", async (
            HttpContext context,
            ApplicationDbContext dbContext) =>
        {
            var userId = context.User.FindFirst(System.Security.Claims.ClaimTypes.NameIdentifier)?.Value;
            if (string.IsNullOrEmpty(userId))
            {
                return Results.Unauthorized();
            }

            var userTenants = await dbContext.TenantUsers
                .Include(tu => tu.Tenant)
                .Where(tu => tu.UserId == userId && tu.IsActive && tu.Tenant.IsActive)
                .Select(tu => new TenantResponse(
                    tu.Tenant.Id,
                    tu.Tenant.Name,
                    tu.Tenant.Slug,
                    tu.Tenant.IsActive,
                    tu.Tenant.Settings,
                    tu.Tenant.CreatedAt,
                    tu.Tenant.UpdatedAt
                ))
                .ToListAsync();

            return Results.Ok(userTenants);
        });

        // POST /api/tenants - Create new tenant
        tenants.MapPost("/", async (
            CreateTenantRequest request,
            HttpContext context,
            ApplicationDbContext dbContext) =>
        {
            var userId = context.User.FindFirst(System.Security.Claims.ClaimTypes.NameIdentifier)?.Value;
            if (string.IsNullOrEmpty(userId))
            {
                return Results.Unauthorized();
            }

            var tenant = new Tenant
            {
                Name = request.Name,
                Slug = request.Slug,
                Settings = request.Settings
            };

            dbContext.Tenants.Add(tenant);

            // Add creator as owner
            var tenantUser = new TenantUser
            {
                TenantId = tenant.Id,
                UserId = userId,
                Role = TenantRole.Owner
            };

            dbContext.TenantUsers.Add(tenantUser);
            await dbContext.SaveChangesAsync();

            var response = new TenantResponse(
                tenant.Id,
                tenant.Name,
                tenant.Slug,
                tenant.IsActive,
                tenant.Settings,
                tenant.CreatedAt,
                tenant.UpdatedAt
            );

            return Results.Created($"/api/tenants/{tenant.Id}", response);
        });

        // GET /api/tenants/{id} - Get tenant by ID
        tenants.MapGet("/{id:guid}", async (
            Guid id,
            ApplicationDbContext dbContext) =>
        {
            var tenant = await dbContext.Tenants.FindAsync(id);
            if (tenant == null)
            {
                return Results.NotFound();
            }

            var response = new TenantResponse(
                tenant.Id,
                tenant.Name,
                tenant.Slug,
                tenant.IsActive,
                tenant.Settings,
                tenant.CreatedAt,
                tenant.UpdatedAt
            );

            return Results.Ok(response);
        });

        return app;
    }

    public static WebApplication MapWorkItemEndpoints(this WebApplication app)
    {
        var workItems = app.MapGroup("/api/work-items").RequireAuthorization();

        // GET /api/work-items - List work items with pagination and filters
        workItems.MapGet("/", async (
            HttpContext context,
            IWorkItemService workItemService,
            int page = 1,
            int pageSize = 20,
            string? type = null,
            string? parentId = null,
            string? search = null) =>
        {
            Guid? parentGuid = null;
            if (!string.IsNullOrEmpty(parentId) && Guid.TryParse(parentId, out var parsedParentId))
            {
                parentGuid = parsedParentId;
            }

            var (items, totalCount) = await workItemService.GetPagedAsync(
                page, pageSize, type, parentGuid, search);

            var responses = items.Select(wi => new WorkItemResponse(
                wi.Id,
                wi.TenantId,
                wi.ParentId,
                wi.Type,
                wi.Subtype,
                wi.Name,
                string.IsNullOrEmpty(wi.Meta)
                    ? null
                    : JsonSerializer.Deserialize<Dictionary<string, object>>(wi.Meta),
                wi.CreatedAt,
                wi.CreatedById,
                wi.CreatedBy?.FullName,
                wi.ModifiedAt,
                wi.ModifiedById,
                wi.ModifiedBy?.FullName
            )).ToList();

            var response = new WorkItemListResponse(responses, totalCount, page, pageSize);
            return Results.Ok(response);
        });

        // GET /api/work-items/{id} - Get single work item
        workItems.MapGet("/{id:guid}", async (
            Guid id,
            IWorkItemService workItemService) =>
        {
            var workItem = await workItemService.GetByIdAsync(id);
            if (workItem == null)
            {
                return Results.NotFound();
            }

            var response = new WorkItemResponse(
                workItem.Id,
                workItem.TenantId,
                workItem.ParentId,
                workItem.Type,
                workItem.Subtype,
                workItem.Name,
                string.IsNullOrEmpty(workItem.Meta)
                    ? null
                    : JsonSerializer.Deserialize<Dictionary<string, object>>(workItem.Meta),
                workItem.CreatedAt,
                workItem.CreatedById,
                workItem.CreatedBy?.FullName,
                workItem.ModifiedAt,
                workItem.ModifiedById,
                workItem.ModifiedBy?.FullName
            );

            return Results.Ok(response);
        });

        // POST /api/work-items - Create new work item
        workItems.MapPost("/", async (
            CreateWorkItemRequest request,
            IWorkItemService workItemService) =>
        {
            var workItem = new WorkItem
            {
                Type = request.Type,
                Subtype = request.Subtype,
                Name = request.Name,
                ParentId = request.ParentId,
                Meta = request.Meta != null
                    ? JsonSerializer.Serialize(request.Meta)
                    : null
            };

            var created = await workItemService.CreateAsync(workItem);

            var response = new WorkItemResponse(
                created.Id,
                created.TenantId,
                created.ParentId,
                created.Type,
                created.Subtype,
                created.Name,
                request.Meta,
                created.CreatedAt,
                created.CreatedById,
                created.CreatedBy?.FullName,
                created.ModifiedAt,
                created.ModifiedById,
                created.ModifiedBy?.FullName
            );

            return Results.Created($"/api/work-items/{created.Id}", response);
        });

        // PUT /api/work-items/{id} - Update work item
        workItems.MapPut("/{id:guid}", async (
            Guid id,
            UpdateWorkItemRequest request,
            IWorkItemService workItemService) =>
        {
            var workItem = new WorkItem
            {
                Type = request.Type,
                Subtype = request.Subtype,
                Name = request.Name,
                ParentId = request.ParentId,
                Meta = request.Meta != null
                    ? JsonSerializer.Serialize(request.Meta)
                    : null
            };

            var updated = await workItemService.UpdateAsync(id, workItem);
            if (updated == null)
            {
                return Results.NotFound();
            }

            var response = new WorkItemResponse(
                updated.Id,
                updated.TenantId,
                updated.ParentId,
                updated.Type,
                updated.Subtype,
                updated.Name,
                string.IsNullOrEmpty(updated.Meta)
                    ? null
                    : JsonSerializer.Deserialize<Dictionary<string, object>>(updated.Meta),
                updated.CreatedAt,
                updated.CreatedById,
                updated.CreatedBy?.FullName,
                updated.ModifiedAt,
                updated.ModifiedById,
                updated.ModifiedBy?.FullName
            );

            return Results.Ok(response);
        });

        // DELETE /api/work-items/{id} - Delete work item
        workItems.MapDelete("/{id:guid}", async (
            Guid id,
            IWorkItemService workItemService) =>
        {
            var deleted = await workItemService.DeleteAsync(id);
            if (!deleted)
            {
                return Results.NotFound();
            }

            return Results.NoContent();
        });

        // GET /api/work-items/{id}/children - Get children of work item
        workItems.MapGet("/{id:guid}/children", async (
            Guid id,
            IWorkItemService workItemService) =>
        {
            var children = await workItemService.GetChildrenAsync(id);

            var responses = children.Select(wi => new WorkItemResponse(
                wi.Id,
                wi.TenantId,
                wi.ParentId,
                wi.Type,
                wi.Subtype,
                wi.Name,
                string.IsNullOrEmpty(wi.Meta)
                    ? null
                    : JsonSerializer.Deserialize<Dictionary<string, object>>(wi.Meta),
                wi.CreatedAt,
                wi.CreatedById,
                wi.CreatedBy?.FullName,
                wi.ModifiedAt,
                wi.ModifiedById,
                wi.ModifiedBy?.FullName
            )).ToList();

            return Results.Ok(responses);
        });

        return app;
    }

    public static WebApplication MapFieldDefinitionEndpoints(this WebApplication app)
    {
        var fields = app.MapGroup("/api/field-definitions").RequireAuthorization();

        // GET /api/field-definitions - List all field definitions for current tenant
        fields.MapGet("/", async (
            IFieldDefinitionService fieldDefinitionService,
            string? entityType = null) =>
        {
            var definitions = string.IsNullOrEmpty(entityType)
                ? await fieldDefinitionService.GetAllAsync()
                : await fieldDefinitionService.GetByEntityTypeAsync(entityType);

            var responses = definitions.Select(fd => new FieldDefinitionResponse(
                fd.Id,
                fd.TenantId,
                fd.EntityType,
                fd.FieldName,
                fd.FieldKey,
                fd.FieldType,
                fd.DisplayOrder,
                fd.IsRequired,
                fd.IsEnabled,
                string.IsNullOrEmpty(fd.ValidationRules)
                    ? null
                    : JsonSerializer.Deserialize<Dictionary<string, object>>(fd.ValidationRules),
                string.IsNullOrEmpty(fd.UiMetadata)
                    ? null
                    : JsonSerializer.Deserialize<Dictionary<string, object>>(fd.UiMetadata),
                fd.CreatedAt,
                fd.UpdatedAt
            )).ToList();

            return Results.Ok(responses);
        });

        // GET /api/field-definitions/{id} - Get single field definition
        fields.MapGet("/{id:guid}", async (
            Guid id,
            IFieldDefinitionService fieldDefinitionService) =>
        {
            var fieldDefinition = await fieldDefinitionService.GetByIdAsync(id);
            if (fieldDefinition == null)
            {
                return Results.NotFound();
            }

            var response = new FieldDefinitionResponse(
                fieldDefinition.Id,
                fieldDefinition.TenantId,
                fieldDefinition.EntityType,
                fieldDefinition.FieldName,
                fieldDefinition.FieldKey,
                fieldDefinition.FieldType,
                fieldDefinition.DisplayOrder,
                fieldDefinition.IsRequired,
                fieldDefinition.IsEnabled,
                string.IsNullOrEmpty(fieldDefinition.ValidationRules)
                    ? null
                    : JsonSerializer.Deserialize<Dictionary<string, object>>(fieldDefinition.ValidationRules),
                string.IsNullOrEmpty(fieldDefinition.UiMetadata)
                    ? null
                    : JsonSerializer.Deserialize<Dictionary<string, object>>(fieldDefinition.UiMetadata),
                fieldDefinition.CreatedAt,
                fieldDefinition.UpdatedAt
            );

            return Results.Ok(response);
        });

        // POST /api/field-definitions - Create new field definition
        fields.MapPost("/", async (
            CreateFieldDefinitionRequest request,
            IFieldDefinitionService fieldDefinitionService) =>
        {
            var fieldDefinition = new FieldDefinition
            {
                EntityType = request.EntityType,
                FieldName = request.FieldName,
                FieldKey = request.FieldKey,
                FieldType = request.FieldType,
                DisplayOrder = request.DisplayOrder,
                IsRequired = request.IsRequired,
                IsEnabled = request.IsEnabled,
                ValidationRules = request.ValidationRules != null
                    ? JsonSerializer.Serialize(request.ValidationRules)
                    : null,
                UiMetadata = request.UiMetadata != null
                    ? JsonSerializer.Serialize(request.UiMetadata)
                    : null
            };

            var created = await fieldDefinitionService.CreateAsync(fieldDefinition);

            var response = new FieldDefinitionResponse(
                created.Id,
                created.TenantId,
                created.EntityType,
                created.FieldName,
                created.FieldKey,
                created.FieldType,
                created.DisplayOrder,
                created.IsRequired,
                created.IsEnabled,
                request.ValidationRules,
                request.UiMetadata,
                created.CreatedAt,
                created.UpdatedAt
            );

            return Results.Created($"/api/field-definitions/{created.Id}", response);
        });

        // PUT /api/field-definitions/{id} - Update field definition
        fields.MapPut("/{id:guid}", async (
            Guid id,
            UpdateFieldDefinitionRequest request,
            IFieldDefinitionService fieldDefinitionService) =>
        {
            var fieldDefinition = new FieldDefinition
            {
                FieldName = request.FieldName,
                FieldKey = request.FieldKey,
                FieldType = request.FieldType,
                DisplayOrder = request.DisplayOrder,
                IsRequired = request.IsRequired,
                IsEnabled = request.IsEnabled,
                ValidationRules = request.ValidationRules != null
                    ? JsonSerializer.Serialize(request.ValidationRules)
                    : null,
                UiMetadata = request.UiMetadata != null
                    ? JsonSerializer.Serialize(request.UiMetadata)
                    : null
            };

            var updated = await fieldDefinitionService.UpdateAsync(id, fieldDefinition);
            if (updated == null)
            {
                return Results.NotFound();
            }

            var response = new FieldDefinitionResponse(
                updated.Id,
                updated.TenantId,
                updated.EntityType,
                updated.FieldName,
                updated.FieldKey,
                updated.FieldType,
                updated.DisplayOrder,
                updated.IsRequired,
                updated.IsEnabled,
                string.IsNullOrEmpty(updated.ValidationRules)
                    ? null
                    : JsonSerializer.Deserialize<Dictionary<string, object>>(updated.ValidationRules),
                string.IsNullOrEmpty(updated.UiMetadata)
                    ? null
                    : JsonSerializer.Deserialize<Dictionary<string, object>>(updated.UiMetadata),
                updated.CreatedAt,
                updated.UpdatedAt
            );

            return Results.Ok(response);
        });

        // DELETE /api/field-definitions/{id} - Soft delete field definition
        fields.MapDelete("/{id:guid}", async (
            Guid id,
            IFieldDefinitionService fieldDefinitionService) =>
        {
            var deleted = await fieldDefinitionService.DeleteAsync(id);
            if (!deleted)
            {
                return Results.NotFound();
            }

            return Results.NoContent();
        });

        // POST /api/field-definitions/reorder - Reorder fields
        fields.MapPost("/reorder", async (
            string entityType,
            ReorderFieldsRequest request,
            IFieldDefinitionService fieldDefinitionService) =>
        {
            await fieldDefinitionService.ReorderAsync(entityType, request.FieldIds);
            return Results.Ok(new { message = "Fields reordered successfully" });
        });

        // POST /api/field-definitions/{id}/validate - Validate a field value
        fields.MapPost("/{id:guid}/validate", async (
            Guid id,
            ValidateFieldValueRequest request,
            IFieldDefinitionService fieldDefinitionService) =>
        {
            var (isValid, errors) = await fieldDefinitionService.ValidateFieldValueAsync(id, request.Value);

            var response = new ValidateFieldValueResponse(isValid, errors);
            return Results.Ok(response);
        });

        return app;
    }
}
