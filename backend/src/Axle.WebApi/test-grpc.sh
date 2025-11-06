#!/bin/bash

# Test script for gRPC streaming
# This demonstrates how updates work end-to-end

echo "🚀 Testing Axle gRPC Streaming"
echo "================================"
echo ""

# Step 1: Login to get a token
echo "📝 Step 1: Logging in..."
LOGIN_RESPONSE=$(curl -s -X POST http://localhost:5103/login \
  -H "Content-Type: application/json" \
  -d '{"email":"test@example.com","password":"Test123!"}')

TOKEN=$(echo $LOGIN_RESPONSE | grep -o '"accessToken":"[^"]*' | cut -d'"' -f4)

if [ -z "$TOKEN" ]; then
  echo "❌ Failed to get access token. Make sure you have a test user."
  echo "   Create one by registering: test@example.com / Test123!"
  exit 1
fi

echo "✅ Got access token"
echo ""

# Step 2: Trigger a test update
echo "📡 Step 2: Triggering a test update..."
UPDATE_RESPONSE=$(curl -s -X POST \
  "http://localhost:5103/api/trigger-update?dataType=users&data=%7B%22totalUsers%22%3A42%2C%22message%22%3A%22Test%20update%22%7D" \
  -H "Authorization: Bearer $TOKEN")

echo "✅ Update triggered: $UPDATE_RESPONSE"
echo ""

# Step 3: Test with a new user registration
echo "👤 Step 3: Creating a new user (this will trigger a real-time update)..."
RANDOM_EMAIL="testuser$(date +%s)@example.com"
REGISTER_RESPONSE=$(curl -s -X POST http://localhost:5103/register \
  -H "Content-Type: application/json" \
  -d "{\"email\":\"$RANDOM_EMAIL\",\"password\":\"Test123!\",\"userName\":\"TestUser\"}")

echo "✅ User registered: $REGISTER_RESPONSE"
echo ""

# Step 4: Instructions
echo "✨ Success!"
echo ""
echo "What happened:"
echo "1. When you registered the user, the backend:"
echo "   - Created the user in the database"
echo "   - Called notifier.NotifyUserChangeAsync()"
echo "   - Sent a real-time update to all subscribed clients"
echo ""
echo "2. Any Flutter client subscribed to 'users' would receive:"
echo "   {\"totalUsers\": X, \"newUserId\": \"...\", \"userName\": \"...\"}"
echo ""
echo "Next steps:"
echo "1. Open the Flutter app"
echo "2. Navigate to 'Live Updates Demo'"
echo "3. Click 'Subscribe' to users"
echo "4. Run this script again"
echo "5. Watch the Flutter UI update in real-time! 🎉"
echo ""
echo "Your access token (for manual testing):"
echo "$TOKEN"
