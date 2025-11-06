# Axle Backend-Frontend Integration Complete

## What Was Built

Your ASP.NET Core Web API backend is now fully integrated with your Flutter frontend!

### Backend Implementation

**Location:** `backend/`

**Technology Stack:**
- ASP.NET Core 9.0
- Entity Framework Core with SQLite
- ASP.NET Core Identity for user management
- JWT Bearer token authentication

**Database:** SQLite (`axle.db` in backend directory)

**API Base URL:** `http://localhost:5103`

### Implemented Endpoints

All endpoints your Flutter app needs are now implemented:

| Endpoint | Method | Description | Auth Required |
|----------|--------|-------------|---------------|
| `/register` | POST | Create new user account | No |
| `/login` | POST | Sign in and get JWT tokens | No |
| `/refresh` | POST | Refresh access token | No |
| `/confirmEmail` | GET | Confirm email with code | No |
| `/resendConfirmationEmail` | POST | Resend confirmation email | No |
| `/forgotPassword` | POST | Request password reset | No |
| `/resetPassword` | POST | Reset password with code | No |
| `/manage/info` | GET | Get current user info | Yes |
| `/weatherforecast` | GET | Sample protected endpoint | Yes |

### Frontend Configuration

**Location:** `frontend/lib/main.dart`

**Changes Made:**
- Set `_useMockAuth = false` (line 25)
- Set `_apiBaseUrl = 'http://localhost:5103'` (line 28)

Your Flutter app is now configured to use the real backend API instead of mock authentication.

## Project Structure

```
backend/
├── Data/
│   └── ApplicationDbContext.cs      # EF Core database context
├── DTOs/
│   ├── RegisterRequest.cs           # Registration request model
│   ├── LoginRequest.cs              # Login request model
│   ├── LoginResponse.cs             # Login response with JWT tokens
│   ├── RefreshTokenRequest.cs       # Token refresh request
│   ├── ForgotPasswordRequest.cs     # Password reset request
│   ├── ResetPasswordRequest.cs      # Password reset confirmation
│   ├── ConfirmEmailRequest.cs       # Email confirmation
│   └── ResendConfirmationRequest.cs # Resend confirmation
├── Models/
│   ├── ApplicationUser.cs           # User entity (extends IdentityUser)
│   └── RefreshToken.cs              # Refresh token entity
├── Services/
│   ├── ITokenService.cs             # Token service interface
│   └── TokenService.cs              # JWT token generation service
├── Program.cs                       # Main application entry point
├── appsettings.json                 # Configuration (JWT, database)
└── Axle.csproj                      # Project file with dependencies
```

## How to Run

### Backend

1. Navigate to backend directory:
   ```bash
   cd backend
   ```

2. Run the API:
   ```bash
   dotnet run
   ```

3. API will be available at:
   - HTTP: `http://localhost:5103`
   - HTTPS: `https://localhost:7289`

### Frontend

1. Navigate to frontend directory:
   ```bash
   cd frontend
   ```

2. Run the Flutter app:
   ```bash
   flutter run
   ```

## Testing the Integration

The backend has been tested and verified working:

1. **Registration:** Creates user account successfully
   ```bash
   curl -X POST http://localhost:5103/register \
     -H "Content-Type: application/json" \
     -d '{"email":"test@example.com","password":"Test123!","userName":"TestUser"}'
   ```

2. **Login:** Returns JWT access token and refresh token
   ```bash
   curl -X POST http://localhost:5103/login \
     -H "Content-Type: application/json" \
     -d '{"email":"test@example.com","password":"Test123!"}'
   ```

3. **Protected Endpoints:** Access token grants access to protected resources
   ```bash
   curl http://localhost:5103/manage/info \
     -H "Authorization: Bearer YOUR_ACCESS_TOKEN"
   ```

4. **Token Refresh:** Refresh token generates new access token
   ```bash
   curl -X POST http://localhost:5103/refresh \
     -H "Content-Type: application/json" \
     -d '{"refreshToken":"YOUR_REFRESH_TOKEN"}'
   ```

## Configuration Details

### JWT Settings (appsettings.json)

```json
{
  "JwtSettings": {
    "SecretKey": "your-super-secret-key-min-32-characters-long-change-in-production",
    "Issuer": "AxleAPI",
    "Audience": "AxleApp",
    "ExpiresInMinutes": "60",
    "RefreshTokenExpiryDays": "7"
  }
}
```

**Important:** Change the `SecretKey` in production to a secure random value.

### Password Requirements

- Minimum 6 characters
- At least 1 digit
- At least 1 lowercase letter
- At least 1 uppercase letter
- Special characters optional

### CORS Configuration

CORS is configured to allow all origins, methods, and headers for development. In production, restrict this to your Flutter app's domain.

## Security Notes

1. **JWT Secret:** The default secret key in `appsettings.json` should be changed to a secure random value in production

2. **Email Confirmation:** Currently disabled (`RequireConfirmedEmail = false`). Enable this in production with a proper email service

3. **HTTPS:** Use HTTPS in production (already configured at `https://localhost:7289`)

4. **CORS:** Restrict CORS to specific origins in production instead of `AllowAnyOrigin()`

5. **Database:** SQLite is fine for development. Consider SQL Server or PostgreSQL for production

## Features Implemented

- User registration with validation
- Secure password hashing (ASP.NET Core Identity)
- JWT access token generation
- Refresh token rotation
- Token expiration and validation
- Email confirmation support (tokens generated, email sending not implemented)
- Password reset support (tokens generated, email sending not implemented)
- User info endpoint
- CORS support for Flutter app
- Protected endpoints with JWT authorization

## Next Steps

To make this production-ready:

1. **Email Service:** Implement email sending for confirmation and password reset
2. **Logging:** Add structured logging with Serilog
3. **Error Handling:** Add global exception handling middleware
4. **Validation:** Add FluentValidation for request validation
5. **Rate Limiting:** Add rate limiting to prevent abuse
6. **Database:** Switch to SQL Server/PostgreSQL for production
7. **Secrets:** Move sensitive config to User Secrets or Azure Key Vault
8. **CORS:** Restrict to specific origins
9. **HTTPS:** Enforce HTTPS in production
10. **Testing:** Add unit and integration tests

## Test User

A test user has been created:
- **Email:** test@example.com
- **Password:** Test123!
- **Username:** TestUser

You can use this to test the Flutter app immediately.

## Support

If you encounter any issues:
1. Check that the backend is running on `http://localhost:5103`
2. Check that the Flutter app is configured with the correct API base URL
3. Check the backend logs for any errors
4. Verify the database file `axle.db` was created in the backend directory

Enjoy your fully integrated Axle app!
