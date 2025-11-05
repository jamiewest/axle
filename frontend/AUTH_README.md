# Authentication Flow

This document describes the authentication flow implementation in the Axle
Flutter application.

## Overview

The authentication system consists of several views and a mockable
`SignInManager` interface that can be replaced with a real authentication
service in production.

## Architecture

### Domain Layer

**SignInManager Interface** ([lib/domain/services/sign_in_manager.dart](lib/domain/services/sign_in_manager.dart))
- Abstract interface defining all authentication operations
- Methods for sign in, sign out, create account, password reset, etc.
- Returns `AuthResult` objects indicating success/failure

**AuthResult Model** ([lib/domain/models/auth_result.dart](lib/domain/models/auth_result.dart))
- Immutable data class representing authentication operation results
- Contains success status, optional message, and optional user ID

### Data Layer

**MockSignInManager** ([lib/data/services/mock_sign_in_manager.dart](lib/data/services/mock_sign_in_manager.dart))
- Mock implementation of `SignInManager` for development and testing
- Simulates network delays (500ms by default)
- Logs verification codes to console using `dart:developer`
- Maintains simple in-memory state for registered accounts

### Presentation Layer

**Authentication Views** ([lib/presentation/auth/](lib/presentation/auth/))
- `LoginView` - Email/password sign in
- `CreateAccountView` - New account registration with name, email, password
- `ForgotPasswordView` - Request password reset code
- `ResetPasswordView` - Reset password with verification code
- `ConfirmAccountView` - Confirm account with verification code

All views include:
- Form validation
- Loading states during async operations
- Error handling with dialogs
- Proper keyboard actions and text input configuration
- Password visibility toggles
- Material 3 design

### Routing

**App Router** ([lib/core/routing/app_router.dart](lib/core/routing/app_router.dart))
- Configures `go_router` for declarative navigation
- Routes authentication views and home view
- Passes `SignInManager` instance to all views via constructor

## Authentication Flow Paths

### Sign Up Flow
1. User clicks "Sign Up" on login screen → `/create-account`
2. User fills form and submits → Account created
3. User is redirected to `/confirm-account` with email
4. User enters verification code (check console logs in dev mode)
5. Account confirmed → Redirected to login (`/`)

### Sign In Flow
1. User enters email/password on login screen (`/`)
2. Credentials validated → Redirected to `/home`
3. User can sign out from home screen → Returns to `/`

### Forgot Password Flow
1. User clicks "Forgot Password?" on login screen → `/forgot-password`
2. User enters email → Reset code sent (check console logs)
3. User redirected to `/reset-password` with email
4. User enters code and new password
5. Password reset → Redirected to login (`/`)

## Mock SignInManager Behavior

### Default Test Account
- Email: `test@example.com`
- Password: Any password with 8+ characters

### Verification Codes
All verification codes are logged to the console using `dart:developer`:
```dart
developer.log('Mock verification code for user@example.com: 123456');
```

Check your IDE's debug console or Flutter DevTools to see codes.

### Configurable Behavior
```dart
final signInManager = MockSignInManager(
  simulateDelay: Duration(milliseconds: 1000), // Slower network
  shouldSucceed: false, // Make all operations fail
);
```

## Replacing with Real Authentication

To integrate with a real authentication service:

1. Create a new class implementing `SignInManager`:
```dart
class FirebaseSignInManager implements SignInManager {
  @override
  Future<AuthResult> signIn({
    required String email,
    required String password,
  }) async {
    // Your Firebase/Auth implementation
  }
  // ... implement other methods
}
```

2. Update [lib/main.dart](lib/main.dart:22):
```dart
// Replace this:
late final _signInManager = MockSignInManager();

// With this:
late final _signInManager = FirebaseSignInManager();
```

## Testing

The `SignInManager` interface makes testing straightforward:

```dart
testWidgets('Login view shows error on invalid credentials', (tester) async {
  final mockManager = MockSignInManager(shouldSucceed: false);

  await tester.pumpWidget(
    MaterialApp(
      home: LoginView(signInManager: mockManager),
    ),
  );

  // Test your widget...
});
```

You can also create custom test doubles:

```dart
class FakeSignInManager implements SignInManager {
  @override
  Future<AuthResult> signIn({
    required String email,
    required String password,
  }) async {
    return AuthResult.failure('Test error');
  }
  // ... implement other methods
}
```

## Features

### Form Validation
- Email format validation
- Password length requirements (minimum 8 characters)
- Password confirmation matching
- Required field validation

### User Experience
- Loading indicators during async operations
- Password visibility toggles
- Keyboard actions (next, done) for smooth navigation
- Error dialogs with clear messages
- Success confirmations before navigation
- Responsive layout with max-width constraints (400px)

### Accessibility
- Semantic form labels
- Icon buttons with tooltips
- Proper keyboard navigation
- Clear error messages

## File Structure

```
lib/
├── core/
│   └── routing/
│       └── app_router.dart           # GoRouter configuration
├── data/
│   └── services/
│       └── mock_sign_in_manager.dart # Mock implementation
├── domain/
│   ├── models/
│   │   └── auth_result.dart          # Result data model
│   └── services/
│       └── sign_in_manager.dart      # Abstract interface
└── presentation/
    ├── auth/
    │   ├── confirm_account_view.dart
    │   ├── create_account_view.dart
    │   ├── forgot_password_view.dart
    │   ├── login_view.dart
    │   └── reset_password_view.dart
    └── home/
        └── home_view.dart            # Post-login view
```

## Running the Application

```bash
# Run on your preferred device
flutter run

# Or for web
flutter run -d chrome
```

When testing the flows, remember to check your IDE's debug console for
verification codes generated by `MockSignInManager`.
