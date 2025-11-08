/// Represents a node in the system (task, project, customer, etc.).
class Node {
  /// Unique identifier for the node.
  final String id;

  /// Tenant this node belongs to.
  final String tenantId;

  /// Workspace this node belongs to (optional).
  final String? workspaceId;

  /// Parent node ID for hierarchical structures (null for root items).
  final String? parentId;

  /// Type of node (e.g., "Task", "Project", "Customer", "Issue").
  final String type;

  /// Subtype for further categorization (e.g., "Bug", "Feature", "Epic").
  final String? subtype;

  /// Display name/title of the node.
  final String name;

  /// JSON metadata containing custom field values.
  final Map<String, dynamic>? meta;

  /// When the node was created.
  final DateTime createdAt;

  /// User who created this node.
  final String createdById;

  /// Name of the user who created this node.
  final String? createdByName;

  /// When the node was last modified.
  final DateTime? modifiedAt;

  /// User who last modified this node.
  final String? modifiedById;

  /// Name of the user who last modified this node.
  final String? modifiedByName;

  const Node({
    required this.id,
    required this.tenantId,
    this.workspaceId,
    this.parentId,
    required this.type,
    this.subtype,
    required this.name,
    this.meta,
    required this.createdAt,
    required this.createdById,
    this.createdByName,
    this.modifiedAt,
    this.modifiedById,
    this.modifiedByName,
  });

  /// Creates a Node from JSON data.
  factory Node.fromJson(Map<String, dynamic> json) {
    return Node(
      id: json['id'] as String,
      tenantId: json['tenantId'] as String,
      workspaceId: json['workspaceId'] as String?,
      parentId: json['parentId'] as String?,
      type: json['type'] as String,
      subtype: json['subtype'] as String?,
      name: json['name'] as String,
      meta: json['meta'] as Map<String, dynamic>?,
      createdAt: DateTime.parse(json['createdAt'] as String),
      createdById: json['createdById'] as String,
      createdByName: json['createdByName'] as String?,
      modifiedAt: json['modifiedAt'] != null
          ? DateTime.parse(json['modifiedAt'] as String)
          : null,
      modifiedById: json['modifiedById'] as String?,
      modifiedByName: json['modifiedByName'] as String?,
    );
  }

  /// Converts the Node to JSON.
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'tenantId': tenantId,
      'workspaceId': workspaceId,
      'parentId': parentId,
      'type': type,
      'subtype': subtype,
      'name': name,
      'meta': meta,
      'createdAt': createdAt.toIso8601String(),
      'createdById': createdById,
      'createdByName': createdByName,
      'modifiedAt': modifiedAt?.toIso8601String(),
      'modifiedById': modifiedById,
      'modifiedByName': modifiedByName,
    };
  }

  /// Creates a copy of this Node with updated fields.
  Node copyWith({
    String? id,
    String? tenantId,
    String? workspaceId,
    String? parentId,
    String? type,
    String? subtype,
    String? name,
    Map<String, dynamic>? meta,
    DateTime? createdAt,
    String? createdById,
    String? createdByName,
    DateTime? modifiedAt,
    String? modifiedById,
    String? modifiedByName,
  }) {
    return Node(
      id: id ?? this.id,
      tenantId: tenantId ?? this.tenantId,
      workspaceId: workspaceId ?? this.workspaceId,
      parentId: parentId ?? this.parentId,
      type: type ?? this.type,
      subtype: subtype ?? this.subtype,
      name: name ?? this.name,
      meta: meta ?? this.meta,
      createdAt: createdAt ?? this.createdAt,
      createdById: createdById ?? this.createdById,
      createdByName: createdByName ?? this.createdByName,
      modifiedAt: modifiedAt ?? this.modifiedAt,
      modifiedById: modifiedById ?? this.modifiedById,
      modifiedByName: modifiedByName ?? this.modifiedByName,
    );
  }
}

/// DTO for creating a new node.
class CreateNodeDto {
  final String type;
  final String name;
  final String? workspaceId;
  final String? subtype;
  final String? parentId;
  final Map<String, dynamic>? meta;

  const CreateNodeDto({
    required this.type,
    required this.name,
    this.workspaceId,
    this.subtype,
    this.parentId,
    this.meta,
  });

  Map<String, dynamic> toJson() {
    return {
      'type': type,
      'name': name,
      if (workspaceId != null) 'workspaceId': workspaceId,
      if (subtype != null) 'subtype': subtype,
      if (parentId != null) 'parentId': parentId,
      if (meta != null) 'meta': meta,
    };
  }
}
