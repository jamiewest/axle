import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:axle/core/config/api_config.dart';
import 'package:axle/core/logging/app_logger.dart';
import 'package:axle/core/exceptions/network_exception.dart';
import 'package:axle/data/services/token_storage_service.dart';
import 'package:axle/domain/models/tenant.dart';

/// Result of a tenant operation.
class TenantResult {
  final bool success;
  final String? message;
  final Tenant? tenant;
  final Map<String, List<String>>? errors;

  const TenantResult({
    required this.success,
    this.message,
    this.tenant,
    this.errors,
  });

  factory TenantResult.success({Tenant? tenant, String? message}) {
    return TenantResult(
      success: true,
      tenant: tenant,
      message: message,
    );
  }

  factory TenantResult.failure(String message, {Map<String, List<String>>? errors}) {
    return TenantResult(
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

/// Result of getting a list of tenants.
class TenantsListResult {
  final bool success;
  final String? message;
  final List<Tenant>? tenants;

  const TenantsListResult({
    required this.success,
    this.message,
    this.tenants,
  });

  factory TenantsListResult.success({required List<Tenant> tenants}) {
    return TenantsListResult(
      success: true,
      tenants: tenants,
    );
  }

  factory TenantsListResult.failure(String message) {
    return TenantsListResult(
      success: false,
      message: message,
    );
  }
}

/// Service for managing tenant operations.
class TenantService {
  TenantService({
    required ApiConfig apiConfig,
    TokenStorageService? tokenStorage,
    http.Client? httpClient,
  })  : _apiConfig = apiConfig,
        _tokenStorage = tokenStorage ?? TokenStorageService(),
        _httpClient = httpClient ?? http.Client();

  final ApiConfig _apiConfig;
  final TokenStorageService _tokenStorage;
  final http.Client _httpClient;
  final AppLogger _logger = AppLogger('TenantService');

  static const String _tenantsPath = '/api/tenants';

  /// Creates a new tenant.
  Future<TenantResult> createTenant({
    required String name,
    required String slug,
  }) async {
    try {
      _logger.logOperationStart('Create tenant', attributes: {'slug': slug});

      final createDto = CreateTenantDto(name: name, slug: slug);
      final response = await _post(
        _tenantsPath,
        body: createDto.toJson(),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final tenant = Tenant.fromJson(
          jsonDecode(response.body) as Map<String, dynamic>,
        );

        _logger.logOperationSuccess('Create tenant', attributes: {
          'tenant_id': tenant.id,
          'tenant_slug': tenant.slug,
        });

        return TenantResult.success(
          tenant: tenant,
          message: 'Tenant created successfully',
        );
      } else if (response.statusCode == 400) {
        final errorData = _parseErrorResponse(response);
        return TenantResult.failure(
          errorData['message'] ?? 'Failed to create tenant',
          errors: errorData['errors'],
        );
      } else if (response.statusCode == 409) {
        return TenantResult.failure(
          'A tenant with this slug already exists',
        );
      } else {
        final errorData = _parseErrorResponse(response);
        return TenantResult.failure(
          errorData['message'] ?? 'Failed to create tenant',
          errors: errorData['errors'],
        );
      }
    } catch (e, stackTrace) {
      _logger.logOperationFailure(
        'Create tenant',
        error: e,
        stackTrace: stackTrace,
        attributes: {
          'error_type': 'network_error',
          'is_network_exception': NetworkExceptionHelper.isNetworkException(e),
        },
      );

      if (NetworkExceptionHelper.isNetworkException(e)) {
        return TenantResult.failure(NetworkExceptionHelper.getUserFriendlyMessage(e));
      }

      return TenantResult.failure('Network error: ${e.toString()}');
    }
  }

  /// Gets all tenants for the current user.
  Future<TenantsListResult> getTenants() async {
    try {
      _logger.logOperationStart('Get tenants');

      final response = await _get(_tenantsPath);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final List<Tenant> tenants = [];

        if (data is List) {
          for (final item in data) {
            tenants.add(Tenant.fromJson(item as Map<String, dynamic>));
          }
        }

        _logger.logOperationSuccess('Get tenants', attributes: {
          'tenant_count': tenants.length,
        });

        return TenantsListResult.success(tenants: tenants);
      } else {
        final errorData = _parseErrorResponse(response);
        return TenantsListResult.failure(
          errorData['message'] ?? 'Failed to retrieve tenants',
        );
      }
    } catch (e, stackTrace) {
      _logger.logOperationFailure(
        'Get tenants',
        error: e,
        stackTrace: stackTrace,
      );

      if (NetworkExceptionHelper.isNetworkException(e)) {
        return TenantsListResult.failure(NetworkExceptionHelper.getUserFriendlyMessage(e));
      }

      return TenantsListResult.failure('Network error: ${e.toString()}');
    }
  }

  /// Gets a single tenant by ID.
  Future<TenantResult> getTenant(String tenantId) async {
    try {
      _logger.logOperationStart('Get tenant', attributes: {'tenant_id': tenantId});

      final response = await _get('$_tenantsPath/$tenantId');

      if (response.statusCode == 200) {
        final tenant = Tenant.fromJson(
          jsonDecode(response.body) as Map<String, dynamic>,
        );

        _logger.logOperationSuccess('Get tenant', attributes: {
          'tenant_id': tenant.id,
        });

        return TenantResult.success(tenant: tenant);
      } else if (response.statusCode == 404) {
        return TenantResult.failure('Tenant not found');
      } else {
        final errorData = _parseErrorResponse(response);
        return TenantResult.failure(
          errorData['message'] ?? 'Failed to retrieve tenant',
        );
      }
    } catch (e, stackTrace) {
      _logger.logOperationFailure(
        'Get tenant',
        error: e,
        stackTrace: stackTrace,
      );

      if (NetworkExceptionHelper.isNetworkException(e)) {
        return TenantResult.failure(NetworkExceptionHelper.getUserFriendlyMessage(e));
      }

      return TenantResult.failure('Network error: ${e.toString()}');
    }
  }

  /// Updates an existing tenant.
  Future<TenantResult> updateTenant({
    required String tenantId,
    required String name,
    required String slug,
    bool isActive = true,
    String? settings,
  }) async {
    try {
      _logger.logOperationStart('Update tenant', attributes: {
        'tenant_id': tenantId,
      });

      final body = <String, dynamic>{
        'name': name,
        'slug': slug,
        'isActive': isActive,
        if (settings != null) 'settings': settings,
      };

      final response = await _put('$_tenantsPath/$tenantId', body: body);

      if (response.statusCode == 200) {
        final tenant = Tenant.fromJson(
          jsonDecode(response.body) as Map<String, dynamic>,
        );

        _logger.logOperationSuccess('Update tenant', attributes: {
          'tenant_id': tenant.id,
        });

        return TenantResult.success(
          tenant: tenant,
          message: 'Tenant updated successfully',
        );
      } else if (response.statusCode == 404) {
        return TenantResult.failure('Tenant not found');
      } else if (response.statusCode == 400) {
        final errorData = _parseErrorResponse(response);
        return TenantResult.failure(
          errorData['message'] ?? 'Failed to update tenant',
          errors: errorData['errors'],
        );
      } else {
        final errorData = _parseErrorResponse(response);
        return TenantResult.failure(
          errorData['message'] ?? 'Failed to update tenant',
          errors: errorData['errors'],
        );
      }
    } catch (e, stackTrace) {
      _logger.logOperationFailure(
        'Update tenant',
        error: e,
        stackTrace: stackTrace,
      );

      if (NetworkExceptionHelper.isNetworkException(e)) {
        return TenantResult.failure(NetworkExceptionHelper.getUserFriendlyMessage(e));
      }

      return TenantResult.failure('Network error: ${e.toString()}');
    }
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
