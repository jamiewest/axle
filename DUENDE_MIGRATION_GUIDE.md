# Duende IdentityServer Migration Guide

## Overview

This guide explains how to migrate from your current JWT implementation to Duende IdentityServer.

## Why Duende IdentityServer?

### Security Benefits
1. **Industry Standard:** OAuth 2.0 and OpenID Connect are battle-tested protocols
2. **Token Security:** Built-in token rotation, revocation, and proof-of-possession
3. **PKCE Support:** Protects mobile apps from authorization code interception
4. **Better Key Management:** Automatic key rotation, HSM support
5. **Audit Trail:** Comprehensive logging of all authentication events

### Scalability Benefits
1. **Multiple Clients:** One auth server for web, mobile, desktop, APIs
2. **Multiple APIs:** Protect multiple backend services with one auth server
3. **Single Sign-On:** Users log in once across all your apps
4. **Federation:** Integrate with external identity providers (Azure AD, Google, etc.)

### Feature Benefits
1. **Social Login:** Easy integration with Google, Facebook, Apple, etc.
2. **Device Flow:** Support for TVs, IoT devices, CLI tools
3. **Consent Screens:** Let users control what apps can access
4. **Admin UI:** Manage clients, users, and tokens through a web interface

## Architecture

### Current Architecture
```
┌─────────────────┐
│   Flutter App   │
│                 │
│  Sends login    │
│  credentials    │
└────────┬────────┘
         │
         │ HTTP POST /login
         │ { email, password }
         │
         ▼
┌─────────────────────────────────┐
│      Your API (Port 5103)       │
│  ┌───────────────────────────┐  │
│  │  ASP.NET Core Identity    │  │
│  │  - User Management        │  │
│  │  - Password Hashing       │  │
│  │  - JWT Generation         │  │
│  └───────────────────────────┘  │
│  ┌───────────────────────────┐  │
│  │  Business Logic           │  │
│  │  - Weather API            │  │
│  │  - User Data              │  │
│  └───────────────────────────┘  │
└─────────────────────────────────┘
```

### Duende IdentityServer Architecture
```
┌─────────────────┐
│   Flutter App   │
│                 │
│  1. Requests    │
│     auth code   │
└────────┬────────┘
         │
         │ OAuth/OIDC flow
         │
         ▼
┌──────────────────────────────────┐
│  Duende IdentityServer (Port 5001) │
│  ┌────────────────────────────┐  │
│  │  ASP.NET Core Identity     │  │
│  │  - User Management         │  │
│  │  - Password Hashing        │  │
│  └────────────────────────────┘  │
│  ┌────────────────────────────┐  │
│  │  OAuth/OIDC Endpoints      │  │
│  │  - /connect/authorize      │  │
│  │  - /connect/token          │  │
│  │  - /connect/userinfo       │  │
│  │  - /connect/revocation     │  │
│  │  - /connect/introspect     │  │
│  └────────────────────────────┘  │
└────────────┬─────────────────────┘
             │ Issues tokens
             │
             ▼
        ┌─────────┐
        │ Tokens  │
        └────┬────┘
             │
             │ 2. Uses tokens
             │    to call API
             ▼
┌──────────────────────────────────┐
│      Your API (Port 5103)        │
│  ┌────────────────────────────┐  │
│  │  Token Validation          │  │
│  │  - Validates JWT signature │  │
│  │  - Checks expiration       │  │
│  └────────────────────────────┘  │
│  ┌────────────────────────────┐  │
│  │  Business Logic            │  │
│  │  - Weather API             │  │
│  │  - User Data               │  │
│  └────────────────────────────┘  │
└──────────────────────────────────┘
```

## Migration Steps

### Phase 1: Set Up Duende IdentityServer (2-3 hours)

1. **Create new IdentityServer project:**
   ```bash
   cd /Users/jamie/Developer/github/axle
   dotnet new web -n IdentityServer
   cd IdentityServer
   ```

2. **Add Duende packages:**
   ```bash
   dotnet add package Duende.IdentityServer
   dotnet add package Duende.IdentityServer.AspNetIdentity
   dotnet add package Duende.IdentityServer.EntityFramework
   dotnet add package Microsoft.AspNetCore.Identity.EntityFrameworkCore
   dotnet add package Microsoft.EntityFrameworkCore.Sqlite
   ```

3. **Configure IdentityServer in Program.cs:**
   - Set up ASP.NET Core Identity
   - Configure IdentityServer with clients and resources
   - Add UI for login/consent (Duende provides templates)

4. **Define Clients (your Flutter app):**
   ```csharp
   new Client
   {
       ClientId = "axle.flutter",
       ClientName = "Axle Flutter App",
       AllowedGrantTypes = GrantTypes.Code,
       RequirePkce = true, // Important for mobile!
       RequireClientSecret = false, // Mobile apps can't keep secrets
       RedirectUris = { "com.axle.app://callback" },
       AllowedScopes = { "openid", "profile", "api" },
       AllowOfflineAccess = true // For refresh tokens
   }
   ```

5. **Define API Resources:**
   ```csharp
   new ApiScope("api", "Axle API")
   ```

6. **Migrate user database:**
   - Copy your existing SQLite database
   - Or configure to use same database as current API

### Phase 2: Update Your API (1-2 hours)

1. **Remove authentication code:**
   - Remove `/login`, `/register` endpoints
   - Remove `TokenService`
   - Keep user management if needed

2. **Add JWT Bearer validation:**
   ```csharp
   builder.Services.AddAuthentication("Bearer")
       .AddJwtBearer("Bearer", options =>
       {
           options.Authority = "http://localhost:5001"; // IdentityServer URL
           options.TokenValidationParameters = new TokenValidationParameters
           {
               ValidateAudience = false
           };
       });
   ```

3. **Update authorization:**
   - Keep `[Authorize]` attributes
   - Add scope requirements if needed

### Phase 3: Update Flutter App (3-4 hours)

1. **Add OAuth/OIDC package:**
   ```yaml
   dependencies:
     flutter_appauth: ^6.0.0
     # Or
     oidc: ^0.5.0
   ```

2. **Replace AspNetCoreIdentitySignInManager:**
   - Implement new `OidcSignInManager`
   - Use authorization code flow with PKCE
   - Handle token storage securely (flutter_secure_storage)

3. **Update login flow:**
   ```dart
   // Instead of username/password POST
   final result = await FlutterAppAuth().authorizeAndExchangeCode(
     AuthorizationTokenRequest(
       'axle.flutter',
       'com.axle.app://callback',
       discoveryUrl: 'http://localhost:5001/.well-known/openid-configuration',
       scopes: ['openid', 'profile', 'api', 'offline_access'],
     ),
   );
   ```

4. **Update token refresh:**
   - Use refresh tokens from OIDC flow
   - Automatic with most OIDC libraries

### Phase 4: Testing (1-2 hours)

1. Test all authentication flows
2. Test token refresh
3. Test API access with tokens
4. Test logout and token revocation

## Cost Consideration

**Duende IdentityServer Licensing:**
- **Free:** Development, testing, personal projects
- **Paid:** Production use in commercial applications
  - Starter Edition: $1,500/year (1 production environment)
  - Business Edition: $15,000/year (unlimited environments)
  - Enterprise Edition: $35,000/year (includes support)

**Free Alternatives:**
- **OpenIddict:** Free, open-source, ASP.NET Core
- **IdentityServer4:** Older version, deprecated but still works
- **Keycloak:** Java-based, feature-rich, open-source
- **Auth0, Okta:** SaaS solutions, free tiers available

## Recommended Path

### If You're Just Starting / Learning
**Stick with current setup.** It's simpler and works fine for:
- Learning authentication concepts
- Personal projects
- Internal tools
- Simple applications

### If You Need Production Features
**Consider OpenIddict first:**
- Free and open-source
- Similar features to Duende
- Good community support
- MIT licensed (truly free)

### If You're Building Enterprise Software
**Use Duende IdentityServer:**
- Industry leader
- Best documentation
- Professional support
- Worth the cost at scale

## OpenIddict Alternative (Free)

If you want OAuth/OIDC without the cost, use OpenIddict:

```bash
dotnet add package OpenIddict.AspNetCore
dotnet add package OpenIddict.EntityFrameworkCore
```

**Pros:**
- Free for all uses (Apache 2.0 license)
- Very similar to Duende
- Active development
- Good documentation

**Cons:**
- Less mature than Duende
- Smaller community
- No commercial support

## Decision Matrix

| Feature | Current Setup | Duende | OpenIddict |
|---------|--------------|--------|------------|
| Cost | Free | $1.5k-35k/year | Free |
| OAuth/OIDC | No | Yes | Yes |
| Mobile PKCE | No | Yes | Yes |
| SSO | No | Yes | Yes |
| Social Login | Manual | Easy | Medium |
| Multi-client | Hard | Easy | Easy |
| Learning Curve | Easy | Medium | Medium |
| Production Ready | Basic | Enterprise | Good |
| Support | Community | Commercial | Community |

## Estimated Migration Time

- **Duende/OpenIddict setup:** 4-6 hours
- **API updates:** 2-3 hours
- **Flutter updates:** 4-6 hours
- **Testing & debugging:** 3-4 hours
- **Total:** 13-19 hours

## My Recommendation

**For your current stage:**
1. **Keep your current setup** for now - it works and is simpler
2. **Add the features you need** (social login can be added to current setup)
3. **Migrate to OpenIddict** when you need:
   - Multiple client apps (web + mobile + desktop)
   - Single Sign-On
   - More advanced security requirements
   - OAuth/OIDC compliance

**When to choose Duende:**
- Building a product with paying customers
- Need commercial support
- Enterprise compliance requirements
- Budget for licensing

## Next Steps

Would you like me to:
1. **Enhance your current setup** with better security features?
2. **Create a proof-of-concept** with OpenIddict?
3. **Provide a detailed Duende migration plan**?
4. **Add social login** to your current setup?

Let me know what direction makes sense for your project!
