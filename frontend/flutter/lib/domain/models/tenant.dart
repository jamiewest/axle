/// Represents a tenant in the multi-tenant system.
class Tenant {
  /// Unique identifier for the tenant.
  final String id;

  /// Display name of the tenant/organization.
  final String name;

  /// URL-friendly slug for the tenant (e.g., acme-corp).
  final String slug;

  /// Whether the tenant is active and can be accessed.
  final bool isActive;

  /// JSON blob for tenant-specific settings and configuration.
  final String? settings;

  /// When the tenant was created.
  final DateTime createdAt;

  /// When the tenant was last modified.
  final DateTime? updatedAt;

  const Tenant({
    required this.id,
    required this.name,
    required this.slug,
    this.isActive = true,
    this.settings,
    required this.createdAt,
    this.updatedAt,
  });

  /// Creates a Tenant from JSON data.
  factory Tenant.fromJson(Map<String, dynamic> json) {
    return Tenant(
      id: json['id'] as String,
      name: json['name'] as String,
      slug: json['slug'] as String,
      isActive: json['isActive'] as bool? ?? true,
      settings: json['settings'] as String?,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: json['updatedAt'] != null
          ? DateTime.parse(json['updatedAt'] as String)
          : null,
    );
  }

  /// Converts the Tenant to JSON.
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'slug': slug,
      'isActive': isActive,
      'settings': settings,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
    };
  }

  /// Creates a copy of this Tenant with updated fields.
  Tenant copyWith({
    String? id,
    String? name,
    String? slug,
    bool? isActive,
    String? settings,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Tenant(
      id: id ?? this.id,
      name: name ?? this.name,
      slug: slug ?? this.slug,
      isActive: isActive ?? this.isActive,
      settings: settings ?? this.settings,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}

/// DTO for creating a new tenant.
class CreateTenantDto {
  final String name;
  final String slug;

  const CreateTenantDto({
    required this.name,
    required this.slug,
  });

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'slug': slug,
    };
  }
}
