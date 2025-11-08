import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:axle/core/config/api_config.dart';
import 'package:axle/core/logging/app_logger.dart';
import 'package:axle/core/exceptions/network_exception.dart';
import 'package:axle/data/services/token_storage_service.dart';
import 'package:axle/domain/models/workspace.dart';

/// Result class for workspace operations
class WorkspaceResult {
  final bool success;
  final String? message;
  final Workspace? workspace;
  final List<Workspace>? workspaces;
  final int? totalCount;

  const WorkspaceResult({
    required this.success,
    this.message,
    this.workspace,
    this.workspaces,
    this.totalCount,
  });

  factory WorkspaceResult.success({
    Workspace? workspace,
    List<Workspace>? workspaces,
    int? totalCount,
  }) {
    return WorkspaceResult(
      success: true,
      workspace: workspace,
      workspaces: workspaces,
      totalCount: totalCount,
    );
  }

  factory WorkspaceResult.failure(String message) {
    return WorkspaceResult(
      success: false,
      message: message,
    );
  }
}

/// Service for managing workspaces
class WorkspaceService {
  final ApiConfig _apiConfig;
  final TokenStorageService _tokenStorage;
  final http.Client _httpClient;
  final AppLogger _logger = AppLogger('WorkspaceService');
  static const String _workspacesPath = '/api/workspaces';

  WorkspaceService({
    required ApiConfig apiConfig,
    TokenStorageService? tokenStorage,
    http.Client? httpClient,
  })  : _apiConfig = apiConfig,
        _tokenStorage = tokenStorage ?? TokenStorageService(),
        _httpClient = httpClient ?? http.Client();

  /// Makes a GET request to the API.
  Future<http.Response> _get(String path) async {
    final uri = Uri.parse('${_apiConfig.baseUrl}$path');
    final accessToken = await _tokenStorage.getAccessToken();

    final headers = {
      'Content-Type': 'application/json',
      if (accessToken != null) 'Authorization': 'Bearer $accessToken',
    };

    return await _httpClient
        .get(uri, headers: headers)
        .timeout(_apiConfig.timeout);
  }

  /// Makes a POST request to the API.
  Future<http.Response> _post(String path, {required Map<String, dynamic> body}) async {
    final uri = Uri.parse('${_apiConfig.baseUrl}$path');
    final accessToken = await _tokenStorage.getAccessToken();

    final headers = {
      'Content-Type': 'application/json',
      if (accessToken != null) 'Authorization': 'Bearer $accessToken',
    };

    return await _httpClient
        .post(uri, headers: headers, body: jsonEncode(body))
        .timeout(_apiConfig.timeout);
  }

  /// Makes a PUT request to the API.
  Future<http.Response> _put(String path, {required Map<String, dynamic> body}) async {
    final uri = Uri.parse('${_apiConfig.baseUrl}$path');
    final accessToken = await _tokenStorage.getAccessToken();

    final headers = {
      'Content-Type': 'application/json',
      if (accessToken != null) 'Authorization': 'Bearer $accessToken',
    };

    return await _httpClient
        .put(uri, headers: headers, body: jsonEncode(body))
        .timeout(_apiConfig.timeout);
  }

  /// Makes a DELETE request to the API.
  Future<http.Response> _delete(String path) async {
    final uri = Uri.parse('${_apiConfig.baseUrl}$path');
    final accessToken = await _tokenStorage.getAccessToken();

    final headers = {
      'Content-Type': 'application/json',
      if (accessToken != null) 'Authorization': 'Bearer $accessToken',
    };

    return await _httpClient
        .delete(uri, headers: headers)
        .timeout(_apiConfig.timeout);
  }

  /// Helper method to parse error responses
  Map<String, dynamic> _parseErrorResponse(http.Response response) {
    try {
      return jsonDecode(response.body) as Map<String, dynamic>;
    } catch (e) {
      return {'message': 'Server error: ${response.statusCode}'};
    }
  }

  /// Creates a new workspace
  Future<WorkspaceResult> createWorkspace({
    required String tenantId,
    required String name,
    String? description,
  }) async {
    try {
      _logger.logOperationStart('Create workspace', attributes: {
        'tenant_id': tenantId,
        'name': name,
      });

      final body = {
        'tenantId': tenantId,
        'name': name,
        if (description != null) 'description': description,
      };

      final response = await _post(_workspacesPath, body: body);

      if (response.statusCode == 200 || response.statusCode == 201) {
        final workspace = Workspace.fromJson(
          jsonDecode(response.body) as Map<String, dynamic>,
        );
        _logger.logOperationSuccess('Create workspace', attributes: {
          'workspace_id': workspace.id,
          'workspace_name': workspace.name,
        });
        return WorkspaceResult.success(workspace: workspace);
      } else {
        final errorData = _parseErrorResponse(response);
        _logger.logOperationFailure('Create workspace',
            error: errorData['message']);
        return WorkspaceResult.failure(
            errorData['message'] ?? 'Failed to create workspace');
      }
    } catch (e, stackTrace) {
      _logger.logOperationFailure('Create workspace',
          error: e, stackTrace: stackTrace);
      if (NetworkExceptionHelper.isNetworkException(e)) {
        return WorkspaceResult.failure(
            NetworkExceptionHelper.getUserFriendlyMessage(e));
      }
      return WorkspaceResult.failure('Network error: ${e.toString()}');
    }
  }

  /// Gets a single workspace by ID
  Future<WorkspaceResult> getWorkspace(String workspaceId) async {
    try {
      _logger.logOperationStart('Get workspace',
          attributes: {'workspace_id': workspaceId});

      final response =
          await _get('$_workspacesPath/$workspaceId');

      if (response.statusCode == 200) {
        final workspace = Workspace.fromJson(
          jsonDecode(response.body) as Map<String, dynamic>,
        );
        _logger.logOperationSuccess('Get workspace', attributes: {
          'workspace_id': workspace.id,
          'workspace_name': workspace.name,
        });
        return WorkspaceResult.success(workspace: workspace);
      } else {
        final errorData = _parseErrorResponse(response);
        return WorkspaceResult.failure(
            errorData['message'] ?? 'Failed to retrieve workspace');
      }
    } catch (e, stackTrace) {
      _logger.logOperationFailure('Get workspace',
          error: e, stackTrace: stackTrace);
      if (NetworkExceptionHelper.isNetworkException(e)) {
        return WorkspaceResult.failure(
            NetworkExceptionHelper.getUserFriendlyMessage(e));
      }
      return WorkspaceResult.failure('Network error: ${e.toString()}');
    }
  }

  /// Gets all workspaces for a tenant with optional pagination
  Future<WorkspaceResult> getWorkspaces({
    required String tenantId,
    int page = 1,
    int pageSize = 50,
    bool? isActive,
  }) async {
    try {
      _logger.logOperationStart('Get workspaces', attributes: {
        'tenant_id': tenantId,
        'page': page,
        'page_size': pageSize,
      });

      final queryParams = {
        'tenantId': tenantId,
        'page': page.toString(),
        'pageSize': pageSize.toString(),
        if (isActive != null) 'isActive': isActive.toString(),
      };

      final queryString = queryParams.entries
          .map((e) => '${e.key}=${Uri.encodeComponent(e.value)}')
          .join('&');
      final response = await _get('$_workspacesPath?$queryString');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as Map<String, dynamic>;
        final workspacesJson = data['items'] as List<dynamic>? ?? [];
        final workspaces = workspacesJson
            .map((json) => Workspace.fromJson(json as Map<String, dynamic>))
            .toList();
        final totalCount = data['totalCount'] as int?;

        _logger.logOperationSuccess('Get workspaces', attributes: {
          'workspace_count': workspaces.length,
          'total_count': totalCount,
        });

        return WorkspaceResult.success(
          workspaces: workspaces,
          totalCount: totalCount,
        );
      } else {
        final errorData = _parseErrorResponse(response);
        return WorkspaceResult.failure(
            errorData['message'] ?? 'Failed to retrieve workspaces');
      }
    } catch (e, stackTrace) {
      _logger.logOperationFailure('Get workspaces',
          error: e, stackTrace: stackTrace);
      if (NetworkExceptionHelper.isNetworkException(e)) {
        return WorkspaceResult.failure(
            NetworkExceptionHelper.getUserFriendlyMessage(e));
      }
      return WorkspaceResult.failure('Network error: ${e.toString()}');
    }
  }

  /// Updates an existing workspace
  Future<WorkspaceResult> updateWorkspace({
    required String workspaceId,
    String? name,
    String? description,
    bool? isActive,
  }) async {
    try {
      _logger.logOperationStart('Update workspace',
          attributes: {'workspace_id': workspaceId});

      final body = <String, dynamic>{};
      if (name != null) body['name'] = name;
      if (description != null) body['description'] = description;
      if (isActive != null) body['isActive'] = isActive;

      if (body.isEmpty) {
        return WorkspaceResult.failure('No fields to update');
      }

      final response =
          await _put('$_workspacesPath/$workspaceId', body: body);

      if (response.statusCode == 200) {
        final workspace = Workspace.fromJson(
          jsonDecode(response.body) as Map<String, dynamic>,
        );
        _logger.logOperationSuccess('Update workspace', attributes: {
          'workspace_id': workspace.id,
          'workspace_name': workspace.name,
        });
        return WorkspaceResult.success(workspace: workspace);
      } else {
        final errorData = _parseErrorResponse(response);
        _logger.logOperationFailure('Update workspace',
            error: errorData['message']);
        return WorkspaceResult.failure(
            errorData['message'] ?? 'Failed to update workspace');
      }
    } catch (e, stackTrace) {
      _logger.logOperationFailure('Update workspace',
          error: e, stackTrace: stackTrace);
      if (NetworkExceptionHelper.isNetworkException(e)) {
        return WorkspaceResult.failure(
            NetworkExceptionHelper.getUserFriendlyMessage(e));
      }
      return WorkspaceResult.failure('Network error: ${e.toString()}');
    }
  }

  /// Deletes a workspace
  Future<WorkspaceResult> deleteWorkspace(String workspaceId) async {
    try {
      _logger.logOperationStart('Delete workspace',
          attributes: {'workspace_id': workspaceId});

      final response =
          await _delete('$_workspacesPath/$workspaceId');

      if (response.statusCode == 200 || response.statusCode == 204) {
        _logger.logOperationSuccess('Delete workspace',
            attributes: {'workspace_id': workspaceId});
        return WorkspaceResult.success();
      } else {
        final errorData = _parseErrorResponse(response);
        _logger.logOperationFailure('Delete workspace',
            error: errorData['message']);
        return WorkspaceResult.failure(
            errorData['message'] ?? 'Failed to delete workspace');
      }
    } catch (e, stackTrace) {
      _logger.logOperationFailure('Delete workspace',
          error: e, stackTrace: stackTrace);
      if (NetworkExceptionHelper.isNetworkException(e)) {
        return WorkspaceResult.failure(
            NetworkExceptionHelper.getUserFriendlyMessage(e));
      }
      return WorkspaceResult.failure('Network error: ${e.toString()}');
    }
  }

  /// Disposes of resources
  void dispose() {
    _httpClient.close();
  }
}
