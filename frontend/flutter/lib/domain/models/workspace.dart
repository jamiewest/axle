import 'package:intl/intl.dart';

/// Represents a workspace within a tenant.
/// Workspaces provide an organizational layer between tenants and nodes.
class Workspace {
  final String id;
  final String tenantId;
  final String name;
  final String? description;
  final bool isActive;
  final DateTime createdAt;
  final String createdById;
  final String? createdByName;
  final DateTime? updatedAt;
  final String? updatedById;
  final String? updatedByName;

  const Workspace({
    required this.id,
    required this.tenantId,
    required this.name,
    this.description,
    required this.isActive,
    required this.createdAt,
    required this.createdById,
    this.createdByName,
    this.updatedAt,
    this.updatedById,
    this.updatedByName,
  });

  factory Workspace.fromJson(Map<String, dynamic> json) {
    return Workspace(
      id: json['id'] as String,
      tenantId: json['tenantId'] as String,
      name: json['name'] as String,
      description: json['description'] as String?,
      isActive: json['isActive'] as bool? ?? true,
      createdAt: DateTime.parse(json['createdAt'] as String),
      createdById: json['createdById'] as String,
      createdByName: json['createdByName'] as String?,
      updatedAt: json['updatedAt'] != null
          ? DateTime.parse(json['updatedAt'] as String)
          : null,
      updatedById: json['updatedById'] as String?,
      updatedByName: json['updatedByName'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'tenantId': tenantId,
      'name': name,
      'description': description,
      'isActive': isActive,
      'createdAt': createdAt.toIso8601String(),
      'createdById': createdById,
      'createdByName': createdByName,
      'updatedAt': updatedAt?.toIso8601String(),
      'updatedById': updatedById,
      'updatedByName': updatedByName,
    };
  }

  Workspace copyWith({
    String? id,
    String? tenantId,
    String? name,
    String? description,
    bool? isActive,
    DateTime? createdAt,
    String? createdById,
    String? createdByName,
    DateTime? updatedAt,
    String? updatedById,
    String? updatedByName,
  }) {
    return Workspace(
      id: id ?? this.id,
      tenantId: tenantId ?? this.tenantId,
      name: name ?? this.name,
      description: description ?? this.description,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt ?? this.createdAt,
      createdById: createdById ?? this.createdById,
      createdByName: createdByName ?? this.createdByName,
      updatedAt: updatedAt ?? this.updatedAt,
      updatedById: updatedById ?? this.updatedById,
      updatedByName: updatedByName ?? this.updatedByName,
    );
  }

  String get formattedCreatedAt {
    return DateFormat('MMM d, yyyy h:mm a').format(createdAt);
  }

  String get formattedUpdatedAt {
    if (updatedAt == null) return 'Never';
    return DateFormat('MMM d, yyyy h:mm a').format(updatedAt!);
  }

  String get relativeCreatedAt {
    final now = DateTime.now();
    final difference = now.difference(createdAt);

    if (difference.inDays > 7) {
      return formattedCreatedAt;
    } else if (difference.inDays > 0) {
      return '${difference.inDays} day${difference.inDays == 1 ? '' : 's'} ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours} hour${difference.inHours == 1 ? '' : 's'} ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes} minute${difference.inMinutes == 1 ? '' : 's'} ago';
    } else {
      return 'Just now';
    }
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Workspace &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          tenantId == other.tenantId &&
          name == other.name &&
          description == other.description &&
          isActive == other.isActive &&
          createdAt == other.createdAt &&
          createdById == other.createdById &&
          updatedAt == other.updatedAt &&
          updatedById == other.updatedById;

  @override
  int get hashCode =>
      id.hashCode ^
      tenantId.hashCode ^
      name.hashCode ^
      description.hashCode ^
      isActive.hashCode ^
      createdAt.hashCode ^
      createdById.hashCode ^
      updatedAt.hashCode ^
      updatedById.hashCode;

  @override
  String toString() {
    return 'Workspace{id: $id, tenantId: $tenantId, name: $name, isActive: $isActive}';
  }
}
