using Axle.Models;
using Microsoft.AspNetCore.Identity.EntityFrameworkCore;
using Microsoft.EntityFrameworkCore;

namespace Axle.Data;

/// <summary>
/// Database context for the application using Identity.
/// </summary>
public class ApplicationDbContext : IdentityDbContext<ApplicationUser>
{
    private readonly IHttpContextAccessor? _httpContextAccessor;

    public ApplicationDbContext(DbContextOptions<ApplicationDbContext> options, IHttpContextAccessor? httpContextAccessor = null)
        : base(options)
    {
        _httpContextAccessor = httpContextAccessor;
    }


    public DbSet<RefreshToken> RefreshTokens { get; set; }
    public DbSet<Tenant> Tenants { get; set; }
    public DbSet<TenantUser> TenantUsers { get; set; }
    public DbSet<Node> Nodes { get; set; }
    public DbSet<FieldDefinition> FieldDefinitions { get; set; }

    /// <summary>
    /// Gets the current tenant ID from the HTTP context.
    /// </summary>
    private Guid? CurrentTenantId =>
        _httpContextAccessor?.HttpContext?.Items["TenantId"] as Guid?;

    protected override void OnModelCreating(ModelBuilder builder)
    {
        base.OnModelCreating(builder);

        // Configure RefreshToken entity
        builder.Entity<RefreshToken>(entity =>
        {
            entity.HasKey(e => e.Id);
            entity.Property(e => e.Token).IsRequired().HasMaxLength(500);
            entity.Property(e => e.UserId).IsRequired();

            // Configure relationship with ApplicationUser
            entity.HasOne(e => e.User)
                .WithMany(u => u.RefreshTokens)
                .HasForeignKey(e => e.UserId)
                .OnDelete(DeleteBehavior.Cascade);

            // Add index for faster token lookups
            entity.HasIndex(e => e.Token);
        });

        // Configure Tenant entity
        builder.Entity<Tenant>(entity =>
        {
            entity.HasKey(e => e.Id);
            entity.Property(e => e.Name).IsRequired().HasMaxLength(200);
            entity.Property(e => e.Slug).IsRequired().HasMaxLength(100);
            entity.Property(e => e.IsActive).IsRequired();

            // Unique constraint on slug (tenant subdomain/identifier)
            entity.HasIndex(e => e.Slug).IsUnique();

            // Index on IsActive for filtering queries
            entity.HasIndex(e => e.IsActive);
        });

        // Configure TenantUser entity (junction table)
        builder.Entity<TenantUser>(entity =>
        {
            entity.HasKey(e => e.Id);

            // Configure relationship with Tenant
            entity.HasOne(e => e.Tenant)
                .WithMany(t => t.TenantUsers)
                .HasForeignKey(e => e.TenantId)
                .OnDelete(DeleteBehavior.Cascade);

            // Configure relationship with ApplicationUser
            entity.HasOne(e => e.User)
                .WithMany(u => u.TenantMemberships)
                .HasForeignKey(e => e.UserId)
                .OnDelete(DeleteBehavior.Cascade);

            // Unique constraint: user can only have one role per tenant
            entity.HasIndex(e => new { e.TenantId, e.UserId }).IsUnique();

            // Index for querying user's tenants
            entity.HasIndex(e => e.UserId);
        });

        // Configure Node entity
        builder.Entity<Node>(entity =>
        {
            entity.HasKey(e => e.Id);
            entity.Property(e => e.Type).IsRequired().HasMaxLength(100);
            entity.Property(e => e.Subtype).HasMaxLength(100);
            entity.Property(e => e.Name).IsRequired().HasMaxLength(500);

            // Configure relationship with Tenant
            entity.HasOne(e => e.Tenant)
                .WithMany(t => t.Nodes)
                .HasForeignKey(e => e.TenantId)
                .OnDelete(DeleteBehavior.Cascade);

            // Configure self-referencing hierarchy (parent-child)
            entity.HasOne(e => e.Parent)
                .WithMany(e => e.Children)
                .HasForeignKey(e => e.ParentId)
                .OnDelete(DeleteBehavior.Restrict); // Prevent cascade delete of children

            // Configure relationship with creator
            entity.HasOne(e => e.CreatedBy)
                .WithMany(u => u.CreatedNodes)
                .HasForeignKey(e => e.CreatedById)
                .OnDelete(DeleteBehavior.Restrict);

            // Configure relationship with modifier
            entity.HasOne(e => e.ModifiedBy)
                .WithMany(u => u.ModifiedNodes)
                .HasForeignKey(e => e.ModifiedById)
                .OnDelete(DeleteBehavior.Restrict);

            // Indexes for common queries
            entity.HasIndex(e => new { e.TenantId, e.Type }); // Query by tenant and type
            entity.HasIndex(e => e.ParentId); // Query children
            entity.HasIndex(e => e.CreatedById); // Query by creator
            entity.HasIndex(e => new { e.TenantId, e.CreatedAt }); // Recent items by tenant

            // Global query filter for tenant isolation (when tenant context is available)
            entity.HasQueryFilter(e => CurrentTenantId == null || e.TenantId == CurrentTenantId);
        });

        // Configure FieldDefinition entity
        builder.Entity<FieldDefinition>(entity =>
        {
            entity.HasKey(e => e.Id);
            entity.Property(e => e.EntityType).IsRequired().HasMaxLength(100);
            entity.Property(e => e.FieldName).IsRequired().HasMaxLength(200);
            entity.Property(e => e.FieldKey).IsRequired().HasMaxLength(100);
            entity.Property(e => e.FieldType).IsRequired().HasMaxLength(50);

            // Configure relationship with Tenant
            entity.HasOne(e => e.Tenant)
                .WithMany(t => t.FieldDefinitions)
                .HasForeignKey(e => e.TenantId)
                .OnDelete(DeleteBehavior.Cascade);

            // Unique constraint: field key must be unique per tenant + entity type
            entity.HasIndex(e => new { e.TenantId, e.EntityType, e.FieldKey }).IsUnique();

            // Index for querying field definitions by entity type
            entity.HasIndex(e => new { e.TenantId, e.EntityType });

            // Index for display order (used when rendering forms)
            entity.HasIndex(e => new { e.TenantId, e.EntityType, e.DisplayOrder });

            // Global query filter for tenant isolation
            entity.HasQueryFilter(e => CurrentTenantId == null || e.TenantId == CurrentTenantId);
        });
    }
}
