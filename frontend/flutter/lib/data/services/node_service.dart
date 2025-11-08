import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:axle/core/config/api_config.dart';
import 'package:axle/core/logging/app_logger.dart';
import 'package:axle/core/exceptions/network_exception.dart';
import 'package:axle/data/services/token_storage_service.dart';
import 'package:axle/domain/models/node.dart';

/// Result of a node operation.
class NodeResult {
  final bool success;
  final String? message;
  final Node? node;
  final Map<String, List<String>>? errors;

  const NodeResult({
    required this.success,
    this.message,
    this.node,
    this.errors,
  });

  factory NodeResult.success({Node? node, String? message}) {
    return NodeResult(
      success: true,
      node: node,
      message: message,
    );
  }

  factory NodeResult.failure(String message, {Map<String, List<String>>? errors}) {
    return NodeResult(
      success: false,
      message: message,
      errors: errors,
    );
  }

  String? get formattedErrors {
    if (errors == null || errors!.isEmpty) return null;

    final buffer = StringBuffer();
    errors!.forEach((field, messages) {
      for (final message in messages) {
        buffer.writeln('• $message');
      }
    });
    return buffer.toString().trim();
  }
}

/// Result of getting a list of nodes.
class NodesListResult {
  final bool success;
  final String? message;
  final List<Node>? nodes;
  final int? totalCount;

  const NodesListResult({
    required this.success,
    this.message,
    this.nodes,
    this.totalCount,
  });

  factory NodesListResult.success({required List<Node> nodes, int? totalCount}) {
    return NodesListResult(
      success: true,
      nodes: nodes,
      totalCount: totalCount,
    );
  }

  factory NodesListResult.failure(String message) {
    return NodesListResult(
      success: false,
      message: message,
    );
  }
}

/// Service for managing node operations.
class NodeService {
  NodeService({
    required ApiConfig apiConfig,
    TokenStorageService? tokenStorage,
    http.Client? httpClient,
  })  : _apiConfig = apiConfig,
        _tokenStorage = tokenStorage ?? TokenStorageService(),
        _httpClient = httpClient ?? http.Client();

  final ApiConfig _apiConfig;
  final TokenStorageService _tokenStorage;
  final http.Client _httpClient;
  final AppLogger _logger = AppLogger('NodeService');

  static const String _nodesPath = '/api/nodes';

  /// Creates a new node.
  Future<NodeResult> createNode({
    required String type,
    required String name,
    String? tenantId,
    String? workspaceId,
    String? subtype,
    String? parentId,
    Map<String, dynamic>? meta,
  }) async {
    try {
      _logger.logOperationStart('Create node', attributes: {'type': type, 'name': name});

      final createDto = CreateNodeDto(
        type: type,
        name: name,
        workspaceId: workspaceId,
        subtype: subtype,
        parentId: parentId,
        meta: meta,
      );

      final response = await _post(
        _nodesPath,
        body: createDto.toJson(),
        tenantId: tenantId,
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final node = Node.fromJson(
          jsonDecode(response.body) as Map<String, dynamic>,
        );

        _logger.logOperationSuccess('Create node', attributes: {
          'node_id': node.id,
          'node_type': node.type,
        });

        return NodeResult.success(
          node: node,
          message: 'Node created successfully',
        );
      } else if (response.statusCode == 400) {
        final errorData = _parseErrorResponse(response);
        return NodeResult.failure(
          errorData['message'] ?? 'Failed to create node',
          errors: errorData['errors'],
        );
      } else {
        final errorData = _parseErrorResponse(response);
        return NodeResult.failure(
          errorData['message'] ?? 'Failed to create node',
          errors: errorData['errors'],
        );
      }
    } catch (e, stackTrace) {
      _logger.logOperationFailure(
        'Create node',
        error: e,
        stackTrace: stackTrace,
        attributes: {
          'error_type': 'network_error',
          'is_network_exception': NetworkExceptionHelper.isNetworkException(e),
        },
      );

      if (NetworkExceptionHelper.isNetworkException(e)) {
        return NodeResult.failure(NetworkExceptionHelper.getUserFriendlyMessage(e));
      }

      return NodeResult.failure('Network error: ${e.toString()}');
    }
  }

  /// Gets a single node by ID.
  Future<NodeResult> getNode(String nodeId) async {
    try {
      _logger.logOperationStart('Get node', attributes: {'node_id': nodeId});

      final response = await _get('${_apiConfig.baseUrl}$_nodesPath/$nodeId');

      if (response.statusCode == 200) {
        final node = Node.fromJson(
          jsonDecode(response.body) as Map<String, dynamic>,
        );

        _logger.logOperationSuccess('Get node', attributes: {
          'node_id': node.id,
          'node_type': node.type,
        });

        return NodeResult.success(node: node);
      } else {
        final errorData = _parseErrorResponse(response);
        return NodeResult.failure(
          errorData['message'] ?? 'Failed to retrieve node',
        );
      }
    } catch (e, stackTrace) {
      _logger.logOperationFailure(
        'Get node',
        error: e,
        stackTrace: stackTrace,
      );

      if (NetworkExceptionHelper.isNetworkException(e)) {
        return NodeResult.failure(NetworkExceptionHelper.getUserFriendlyMessage(e));
      }

      return NodeResult.failure('Network error: ${e.toString()}');
    }
  }

  /// Gets all nodes for the current tenant with optional filters.
  Future<NodesListResult> getNodes({
    int page = 1,
    int pageSize = 20,
    String? type,
    String? parentId,
    String? search,
  }) async {
    try {
      _logger.logOperationStart('Get nodes', attributes: {
        'page': page,
        'pageSize': pageSize,
        'type': type ?? 'all',
      });

      final queryParams = <String, String>{
        'page': page.toString(),
        'pageSize': pageSize.toString(),
        if (type != null) 'type': type,
        if (parentId != null) 'parentId': parentId,
        if (search != null) 'search': search,
      };

      final uri = Uri.parse('${_apiConfig.baseUrl}$_nodesPath')
          .replace(queryParameters: queryParams);

      final response = await _get(uri.toString());

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as Map<String, dynamic>;
        final List<Node> nodes = [];

        if (data['items'] is List) {
          for (final item in data['items'] as List) {
            nodes.add(Node.fromJson(item as Map<String, dynamic>));
          }
        }

        final totalCount = data['totalCount'] as int?;

        _logger.logOperationSuccess('Get nodes', attributes: {
          'node_count': nodes.length,
          'total_count': totalCount,
        });

        return NodesListResult.success(nodes: nodes, totalCount: totalCount);
      } else {
        final errorData = _parseErrorResponse(response);
        return NodesListResult.failure(
          errorData['message'] ?? 'Failed to retrieve nodes',
        );
      }
    } catch (e, stackTrace) {
      _logger.logOperationFailure(
        'Get nodes',
        error: e,
        stackTrace: stackTrace,
      );

      if (NetworkExceptionHelper.isNetworkException(e)) {
        return NodesListResult.failure(NetworkExceptionHelper.getUserFriendlyMessage(e));
      }

      return NodesListResult.failure('Network error: ${e.toString()}');
    }
  }

  /// Makes a POST request to the API.
  Future<http.Response> _post(String path, {required Map<String, dynamic> body, String? tenantId}) async {
    final uri = Uri.parse('${_apiConfig.baseUrl}$path');
    final accessToken = await _tokenStorage.getAccessToken();

    final headers = {
      'Content-Type': 'application/json',
      if (accessToken != null) 'Authorization': 'Bearer $accessToken',
      if (tenantId != null) 'X-Tenant-Id': tenantId,
    };

    return await _httpClient
        .post(uri, headers: headers, body: jsonEncode(body))
        .timeout(_apiConfig.timeout);
  }

  /// Makes a GET request to the API.
  Future<http.Response> _get(String url) async {
    final uri = Uri.parse(url);
    final accessToken = await _tokenStorage.getAccessToken();

    final headers = {
      'Content-Type': 'application/json',
      if (accessToken != null) 'Authorization': 'Bearer $accessToken',
    };

    return await _httpClient
        .get(uri, headers: headers)
        .timeout(_apiConfig.timeout);
  }

  /// Parses error response from the API.
  Map<String, dynamic> _parseErrorResponse(http.Response response) {
    try {
      final data = jsonDecode(response.body) as Map<String, dynamic>;

      // Handle ASP.NET Core validation errors
      if (data.containsKey('errors')) {
        final errors = data['errors'] as Map<String, dynamic>;
        final formattedErrors = <String, List<String>>{};

        errors.forEach((key, value) {
          if (value is List) {
            formattedErrors[key] = value.cast<String>();
          } else if (value is String) {
            formattedErrors[key] = [value];
          }
        });

        return {
          'message': data['title'] ?? data['message'] ?? 'Validation failed',
          'errors': formattedErrors,
        };
      }

      return {
        'message': data['message'] ?? data['title'] ?? 'Request failed',
      };
    } catch (e) {
      return {
        'message': 'Server error (${response.statusCode})',
      };
    }
  }

  void dispose() {
    _httpClient.close();
  }
}
