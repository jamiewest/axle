using System.Text;
using Axle.Data;
using Axle.DTOs;
using Axle.Extensions;
using Axle.Models;
using Axle.Services;
using Microsoft.AspNetCore.Authentication.JwtBearer;
using Microsoft.AspNetCore.Identity;
using Microsoft.EntityFrameworkCore;
using Microsoft.IdentityModel.Tokens;

var builder = WebApplication.CreateBuilder(args);

// Add services to the container
builder.Services.AddOpenApi();

// Configure database
builder.Services.AddDbContext<ApplicationDbContext>(options =>
    options.UseSqlite(builder.Configuration.GetConnectionString("DefaultConnection")));

// Configure Identity
builder.Services.AddIdentity<ApplicationUser, IdentityRole>(options =>
{
    // Password settings
    options.Password.RequireDigit = true;
    options.Password.RequireLowercase = true;
    options.Password.RequireUppercase = true;
    options.Password.RequireNonAlphanumeric = false;
    options.Password.RequiredLength = 6;

    // Email confirmation
    options.SignIn.RequireConfirmedEmail = false; // Set to true in production with email service

    // User settings
    options.User.RequireUniqueEmail = true;
})
.AddEntityFrameworkStores<ApplicationDbContext>()
.AddDefaultTokenProviders();

// Configure JWT authentication
var jwtSettings = builder.Configuration.GetSection("JwtSettings");
var secretKey = jwtSettings["SecretKey"] ?? throw new InvalidOperationException("JWT SecretKey not configured");

builder.Services.AddAuthentication(options =>
{
    options.DefaultAuthenticateScheme = JwtBearerDefaults.AuthenticationScheme;
    options.DefaultChallengeScheme = JwtBearerDefaults.AuthenticationScheme;
})
.AddJwtBearer(options =>
{
    options.TokenValidationParameters = new TokenValidationParameters
    {
        ValidateIssuer = true,
        ValidateAudience = true,
        ValidateLifetime = true,
        ValidateIssuerSigningKey = true,
        ValidIssuer = jwtSettings["Issuer"],
        ValidAudience = jwtSettings["Audience"],
        IssuerSigningKey = new SymmetricSecurityKey(Encoding.UTF8.GetBytes(secretKey))
    };
});

builder.Services.AddAuthorization();

// Register custom services
builder.Services.AddScoped<ITokenService, TokenService>();
builder.Services.AddSingleton<IUpdateNotifier, UpdateNotifier>();

// Register email service (fake for dev, production for prod)
var useFakeEmail = builder.Configuration.GetValue<bool>("EmailSettings:UseFakeEmailService");
if (useFakeEmail)
{
    builder.Services.AddSingleton<IEmailService, FakeEmailService>();
}
else
{
    builder.Services.AddSingleton<IEmailService, ProductionEmailService>();
}

// Add gRPC
builder.Services.AddGrpc();

// Configure CORS for Flutter app and gRPC
builder.Services.AddCors(options =>
{
    options.AddPolicy("AllowFlutterApp", policy =>
    {
        policy.AllowAnyOrigin()
              .AllowAnyMethod()
              .AllowAnyHeader()
              .WithExposedHeaders("Grpc-Status", "Grpc-Message", "Grpc-Encoding", "Grpc-Accept-Encoding");
    });
});

var app = builder.Build();

// Configure the HTTP request pipeline
if (app.Environment.IsDevelopment())
{
    app.MapOpenApi();
}

app.UseHttpsRedirection();
app.UseCors("AllowFlutterApp");
app.UseAuthentication();
app.UseAuthorization();

// ==================== Authentication Endpoints ====================

// POST /register
app.MapPost("/register", async (
    RegisterRequest request,
    UserManager<ApplicationUser> userManager,
    IUpdateNotifier notifier,
    IEmailService emailService,
    ApplicationDbContext context) =>
{
    var user = new ApplicationUser
    {
        UserName = request.UserName ?? request.Email,
        Email = request.Email,
        FullName = request.UserName
    };

    var result = await userManager.CreateAsync(user, request.Password);

    if (!result.Succeeded)
    {
        return Results.BadRequest(new { errors = result.Errors.Select(e => e.Description) });
    }

    // Generate email confirmation token
    var confirmationToken = await userManager.GenerateEmailConfirmationTokenAsync(user);

    // Send verification email
    await emailService.SendVerificationEmailAsync(user.Email!, confirmationToken, user.Id);

    // Notify subscribers about new user (gRPC real-time update)
    var totalUsers = await context.Users.CountAsync();
    await notifier.NotifyUserChangeAsync(
        Axle.Grpc.ChangeType.Created,
        new { totalUsers, newUserId = user.Id, userName = user.UserName }
    );

    return Results.Ok(new
    {
        message = "User registered successfully. Please check your email for verification code.",
        userId = user.Id
    });
})
.WithName("Register");

// POST /login
app.MapPost("/login", async (
    LoginRequest request,
    UserManager<ApplicationUser> userManager,
    SignInManager<ApplicationUser> signInManager,
    ITokenService tokenService,
    ApplicationDbContext context) =>
{
    var user = await userManager.FindByEmailAsync(request.Email);
    if (user == null)
    {
        return Results.Unauthorized();
    }

    var result = await signInManager.CheckPasswordSignInAsync(user, request.Password, lockoutOnFailure: false);

    if (!result.Succeeded)
    {
        return Results.Unauthorized();
    }

    // Get user roles
    var roles = await userManager.GetRolesAsync(user);

    // Generate tokens
    var accessToken = tokenService.GenerateAccessToken(user, roles);
    var refreshToken = tokenService.GenerateRefreshToken(user.Id);

    // Save refresh token to database
    context.RefreshTokens.Add(refreshToken);
    await context.SaveChangesAsync();

    var response = new LoginResponse
    {
        AccessToken = accessToken,
        RefreshToken = refreshToken.Token,
        ExpiresIn = int.Parse(jwtSettings["ExpiresInMinutes"] ?? "60") * 60, // Convert to seconds
        TokenType = "Bearer"
    };

    return Results.Ok(response);
})
.WithName("Login");

// POST /refresh
app.MapPost("/refresh", async (
    RefreshTokenRequest request,
    ITokenService tokenService,
    UserManager<ApplicationUser> userManager,
    ApplicationDbContext context) =>
{
    var user = await tokenService.ValidateRefreshTokenAsync(request.RefreshToken);

    if (user == null)
    {
        return Results.Unauthorized();
    }

    // Revoke old refresh token
    await tokenService.RevokeRefreshTokenAsync(request.RefreshToken);

    // Get user roles
    var roles = await userManager.GetRolesAsync(user);

    // Generate new tokens
    var accessToken = tokenService.GenerateAccessToken(user, roles);
    var newRefreshToken = tokenService.GenerateRefreshToken(user.Id);

    // Save new refresh token
    context.RefreshTokens.Add(newRefreshToken);
    await context.SaveChangesAsync();

    var response = new LoginResponse
    {
        AccessToken = accessToken,
        RefreshToken = newRefreshToken.Token,
        ExpiresIn = int.Parse(jwtSettings["ExpiresInMinutes"] ?? "60") * 60,
        TokenType = "Bearer"
    };

    return Results.Ok(response);
})
.WithName("RefreshToken");

// GET /confirmEmail
app.MapGet("/confirmEmail", async (
    string userId,
    string code,
    UserManager<ApplicationUser> userManager) =>
{
    var user = await userManager.FindByIdAsync(userId);
    if (user == null)
    {
        return Results.BadRequest(new { error = "Invalid user ID" });
    }

    var result = await userManager.ConfirmEmailAsync(user, code);

    if (!result.Succeeded)
    {
        return Results.BadRequest(new { errors = result.Errors.Select(e => e.Description) });
    }

    return Results.Ok(new { message = "Email confirmed successfully" });
})
.WithName("ConfirmEmail");

// POST /resendConfirmationEmail
app.MapPost("/resendConfirmationEmail", async (
    ResendConfirmationRequest request,
    UserManager<ApplicationUser> userManager,
    IEmailService emailService) =>
{
    var user = await userManager.FindByEmailAsync(request.Email);
    if (user == null)
    {
        // Don't reveal that the user doesn't exist
        return Results.Ok(new { message = "If the email exists, a confirmation link has been sent" });
    }

    if (await userManager.IsEmailConfirmedAsync(user))
    {
        return Results.BadRequest(new { error = "Email is already confirmed" });
    }

    var confirmationToken = await userManager.GenerateEmailConfirmationTokenAsync(user);

    // Send verification email
    await emailService.SendVerificationEmailAsync(user.Email!, confirmationToken, user.Id);

    return Results.Ok(new
    {
        message = "Confirmation email sent. Please check your email for verification code."
    });
})
.WithName("ResendConfirmationEmail");

// POST /forgotPassword
app.MapPost("/forgotPassword", async (
    ForgotPasswordRequest request,
    UserManager<ApplicationUser> userManager,
    IEmailService emailService) =>
{
    var user = await userManager.FindByEmailAsync(request.Email);

    // Don't reveal whether a user exists or not
    if (user == null)
    {
        return Results.Ok(new { message = "If the email exists, a password reset link has been sent" });
    }

    var resetToken = await userManager.GeneratePasswordResetTokenAsync(user);

    // Send password reset email
    await emailService.SendPasswordResetEmailAsync(user.Email!, resetToken, user.Id);

    return Results.Ok(new
    {
        message = "Password reset link sent. Please check your email."
    });
})
.WithName("ForgotPassword");

// POST /resetPassword
app.MapPost("/resetPassword", async (
    ResetPasswordRequest request,
    UserManager<ApplicationUser> userManager) =>
{
    var user = await userManager.FindByEmailAsync(request.Email);
    if (user == null)
    {
        return Results.BadRequest(new { error = "Invalid request" });
    }

    var result = await userManager.ResetPasswordAsync(user, request.Code, request.NewPassword);

    if (!result.Succeeded)
    {
        return Results.BadRequest(new { errors = result.Errors.Select(e => e.Description) });
    }

    return Results.Ok(new { message = "Password reset successfully" });
})
.WithName("ResetPassword");

// GET /manage/info - Protected endpoint example
app.MapGet("/manage/info", async (HttpContext context, UserManager<ApplicationUser> userManager) =>
{
    var userId = context.User.FindFirst(System.Security.Claims.ClaimTypes.NameIdentifier)?.Value;

    if (string.IsNullOrEmpty(userId))
    {
        return Results.Unauthorized();
    }

    var user = await userManager.FindByIdAsync(userId);
    if (user == null)
    {
        return Results.NotFound();
    }

    return Results.Ok(new
    {
        email = user.Email,
        userName = user.UserName,
        fullName = user.FullName,
        emailConfirmed = user.EmailConfirmed,
        twoFactorEnabled = user.TwoFactorEnabled
    });
})
.RequireAuthorization()
.WithName("GetUserInfo");

// GET /dev/verification-code - Development only endpoint to get verification code
app.MapGet("/dev/verification-code", (
    string email,
    IEmailService emailService,
    IWebHostEnvironment env) =>
{
    if (!env.IsDevelopment())
    {
        return Results.NotFound();
    }

    var code = emailService.GetLastVerificationCode(email);
    if (code == null)
    {
        return Results.NotFound(new { message = "No verification code found for this email" });
    }

    return Results.Ok(new
    {
        email,
        verificationCode = code,
        message = "This endpoint is only available in development mode"
    });
})
.WithName("GetDevVerificationCode");

// Sample protected endpoint - Weather Forecast
app.MapGet("/weatherforecast", () =>
{
    var summaries = new[]
    {
        "Freezing", "Bracing", "Chilly", "Cool", "Mild", "Warm", "Balmy", "Hot", "Sweltering", "Scorching"
    };

    var forecast = Enumerable.Range(1, 5).Select(index =>
        new WeatherForecast
        (
            DateOnly.FromDateTime(DateTime.Now.AddDays(index)),
            Random.Shared.Next(-20, 55),
            summaries[Random.Shared.Next(summaries.Length)]
        ))
        .ToArray();
    return forecast;
})
.RequireAuthorization()
.WithName("GetWeatherForecast");

// Map gRPC services
app.MapGrpcService<Axle.Grpc.Services.UpdateStreamService>();

// Test endpoint to trigger updates (for demonstration)
app.MapPost("/api/trigger-update", async (
    string dataType,
    string data,
    IUpdateNotifier notifier) =>
{
    await notifier.NotifyAsync(dataType, Axle.Grpc.ChangeType.Updated, data);
    return Results.Ok(new { message = "Update triggered" });
})
.RequireAuthorization()
.WithName("TriggerUpdate");

// Ensure database is created
using (var scope = app.Services.CreateScope())
{
    var dbContext = scope.ServiceProvider.GetRequiredService<ApplicationDbContext>();
    dbContext.Database.EnsureCreated();
}

app.Run();

record WeatherForecast(DateOnly Date, int TemperatureC, string? Summary)
{
    public int TemperatureF => 32 + (int)(TemperatureC / 0.5556);
}
