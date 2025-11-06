# ASP.NET Core Identity Integration

This document describes the integration between the Flutter frontend and
ASP.NET Core Identity Web API.

## Overview

The application now supports both mock authentication (for development) and
real ASP.NET Core Identity API integration. You can switch between them by
changing a single flag in [lib/main.dart](lib/main.dart).

## Architecture

### SignInManager Implementations

1. **MockSignInManager** - For local development and testing
2. **AspNetCoreIdentitySignInManager** - For production API integration

Both implement the same `SignInManager` interface, making them
interchangeable.

### Key Components

#### API Configuration ([lib/core/config/api_config.dart](lib/core/config/api_config.dart))
```dart
final apiConfig = ApiConfig(
  baseUrl: 'https://your-api.com',
  timeout: Duration(seconds: 30),
);
```

#### Token Storage ([lib/data/services/token_storage_service.dart](lib/data/services/token_storage_service.dart))
- Securely stores JWT tokens using `flutter_secure_storage`
- Manages access token, refresh token, and expiry
- Automatic token expiration checking
- Token refresh capability

#### API Models ([lib/data/models/](lib/data/models/))
Request and response models matching ASP.NET Core Identity format:
- `RegisterRequest` - User registration
- `LoginRequest` - User login with 2FA support
- `LoginResponse` - JWT token response
- `ForgotPasswordRequest` - Password reset initiation
- `ResetPasswordRequest` - Password reset completion
- `ConfirmEmailRequest` - Email confirmation
- `ResendConfirmationRequest` - Resend confirmation email

## ASP.NET Core Identity Endpoints

The implementation expects these standard ASP.NET Core Identity endpoints:

| Endpoint | Method | Purpose |
|----------|--------|---------|
| `/register` | POST | Create new user account |
| `/login` | POST | Sign in and get JWT tokens |
| `/refresh` | POST | Refresh access token |
| `/confirmEmail` | GET | Confirm email with code |
| `/resendConfirmationEmail` | POST | Resend confirmation email |
| `/forgotPassword` | POST | Request password reset |
| `/resetPassword` | POST | Reset password with code |
| `/manage/info` | GET | Get current user info |
| `/manage/2fa` | POST | Manage 2FA settings |

## Configuration

### Switching Between Mock and Real API

In [lib/main.dart](lib/main.dart:25):

```dart
class _MainAppState extends State<MainApp> {
  /// Set to false to use real ASP.NET Core Identity API.
  static const bool _useMockAuth = true;  // Change to false for production

  /// API configuration for production use.
  static const String _apiBaseUrl = 'http://localhost:5000';
  // ...
}
```

### Development Mode (Mock)
```dart
static const bool _useMockAuth = true;
```
- Uses `MockSignInManager`
- No network calls
- Verification codes logged to console
- Simulated delays (500ms)

### Production Mode (Real API)
```dart
static const bool _useMockAuth = false;
static const String _apiBaseUrl = 'https://your-api.com';
```
- Uses `AspNetCoreIdentitySignInManager`
- Real HTTP requests to your API
- JWT token management
- Secure token storage

## Request/Response Format

### Registration Request
```json
POST /register
{
  "email": "user@example.com",
  "password": "SecurePassword123!",
  "userName": "user@example.com"
}
```

### Login Request
```json
POST /login
{
  "email": "user@example.com",
  "password": "SecurePassword123!",
  "twoFactorCode": "123456",       // Optional
  "twoFactorRecoveryCode": "abc123" // Optional
}
```

### Login Response
```json
{
  "accessToken": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...",
  "expiresIn": 3600,
  "refreshToken": "refresh_token_here",
  "tokenType": "Bearer"
}
```

### Error Response
ASP.NET Core Identity returns validation errors in this format:
```json
{
  "type": "https://tools.ietf.org/html/rfc7231#section-6.5.1",
  "title": "One or more validation errors occurred.",
  "status": 400,
  "errors": {
    "Password": [
      "Passwords must be at least 8 characters.",
      "Passwords must have at least one uppercase ('A'-'Z')."
    ],
    "Email": [
      "The Email field is required."
    ]
  }
}
```

The app automatically formats these errors for display to the user.

## Authentication Flow

### Sign Up Flow
1. User enters email, password, and name
2. POST to `/register`
3. Success → Show dialog to check email
4. User enters confirmation code from email
5. GET to `/confirmEmail?userId={email}&code={code}`
6. Success → Redirect to login

### Sign In Flow
1. User enters email and password
2. POST to `/login`
3. Success → Store tokens securely
4. Fetch user info from `/manage/info`
5. Cache user ID
6. Navigate to home screen

### Token Management
1. Access token stored in secure storage
2. Before each authenticated request:
   - Check if token is expired
   - If expired, attempt refresh with refresh token
   - If refresh fails, sign out user
3. Authorization header: `Bearer {accessToken}`

### Password Reset Flow
1. User enters email on forgot password screen
2. POST to `/forgotPassword`
3. User receives reset code via email
4. User enters code and new password
5. POST to `/resetPassword`
6. Success → Redirect to login

## Error Handling

### Network Errors
- Automatic timeout after 30 seconds (configurable)
- User-friendly error messages
- Logging with `dart:developer`

### Validation Errors
- ASP.NET Core Identity validation errors parsed and displayed
- Multi-field error support
- Formatted error messages in dialogs

### Authentication States
The `AuthResult` class supports multiple states:
- `success` - Operation completed successfully
- `failure` - Operation failed with error message
- `requiresEmailConfirmation` - Email confirmation needed
- `requiresTwoFactor` - 2FA required

## Security Features

### Secure Token Storage
- Uses `flutter_secure_storage`
- Platform-specific secure storage:
  - iOS: Keychain
  - Android: EncryptedSharedPreferences
  - Web: Encrypted browser storage
  - Desktop: Platform secure storage

### Token Expiration
- Automatic expiration checking
- Token refresh before expiration
- Automatic sign-out on refresh failure

### HTTPS Support
- Ensure your production API uses HTTPS
- Update `_apiBaseUrl` with `https://` prefix

## Testing

### Unit Testing with Mock Manager
```dart
testWidgets('Login shows error on invalid credentials', (tester) async {
  final mockManager = MockSignInManager(shouldSucceed: false);

  await tester.pumpWidget(
    MaterialApp(home: LoginView(signInManager: mockManager)),
  );

  // Test login failure handling
});
```

### Integration Testing with Real API
```dart
testWidgets('Login integrates with real API', (tester) async {
  final apiConfig = ApiConfig(baseUrl: 'http://localhost:5000');
  final manager = AspNetCoreIdentitySignInManager(apiConfig: apiConfig);

  await tester.pumpWidget(
    MaterialApp(home: LoginView(signInManager: manager)),
  );

  // Test real API integration
});
```

## Backend Requirements

Your ASP.NET Core Identity API should:

1. **Return JWT tokens** in the login response with these fields:
   - `accessToken` (string)
   - `expiresIn` (number, seconds)
   - `refreshToken` (string)
   - `tokenType` (string, default "Bearer")

2. **Support standard endpoints** listed above

3. **Use standard ASP.NET Core validation error format**

4. **Enable CORS** for your Flutter app domain (for web)

5. **Support bearer token authentication** for protected endpoints

## Example ASP.NET Core Setup

Minimal endpoint configuration:

```csharp
// Program.cs
app.MapPost("/register", async (RegisterRequest req,
    UserManager<IdentityUser> userManager) =>
{
    var user = new IdentityUser
    {
        UserName = req.Email,
        Email = req.Email
    };

    var result = await userManager.CreateAsync(user, req.Password);

    if (result.Succeeded)
    {
        // Send confirmation email
        return Results.Ok();
    }

    return Results.BadRequest(result.Errors);
});

app.MapPost("/login", async (LoginRequest req,
    SignInManager<IdentityUser> signInManager,
    ITokenService tokenService) =>
{
    var result = await signInManager.PasswordSignInAsync(
        req.Email, req.Password, false, false);

    if (result.Succeeded)
    {
        var tokens = await tokenService.GenerateTokens(req.Email);
        return Results.Ok(tokens);
    }

    return Results.Unauthorized();
});
```

## Troubleshooting

### Tokens Not Persisting
- Check secure storage permissions on the platform
- Verify `flutter_secure_storage` setup for your platform

### Network Errors
- Verify `_apiBaseUrl` is correct
- Check API is running and accessible
- Ensure CORS is configured on backend
- Check network connectivity

### Validation Errors Not Showing
- Verify API returns errors in ASP.NET Core format
- Check console logs for parsing errors

### Token Refresh Failing
- Verify `/refresh` endpoint is implemented
- Check refresh token is being stored correctly
- Ensure refresh token hasn't expired

## Platform-Specific Setup

### Android
No additional setup required.

### iOS
No additional setup required.

### Web
Update `_apiBaseUrl` to your deployed API URL.
Ensure CORS is configured on your backend.

### Desktop
Secure storage works out of the box on macOS, Linux, and Windows.

## Migration from Mock to Production

1. Set `_useMockAuth = false` in [lib/main.dart](lib/main.dart:25)
2. Update `_apiBaseUrl` to your production API
3. Ensure your API endpoints match the expected format
4. Test all authentication flows thoroughly
5. Monitor logs for any integration issues

## Additional Resources

- [ASP.NET Core Identity Documentation](https://learn.microsoft.com/en-us/aspnet/core/security/authentication/identity)
- [flutter_secure_storage Package](https://pub.dev/packages/flutter_secure_storage)
- [http Package Documentation](https://pub.dev/packages/http)
- [JWT.io - JWT Debugger](https://jwt.io/)
