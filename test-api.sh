#!/bin/bash

# JWT Authentication Service Test Script
BASE_URL="http://localhost:8080"

echo "=== Testing JWT Authentication Service ==="
echo

# Test 1: Register a new user
echo "1. Registering a new user..."
REGISTER_RESPONSE=$(curl -s -X POST $BASE_URL/api/auth/register \
  -H "Content-Type: application/json" \
  -d '{
    "name": "Test User",
    "email": "testuser@example.com",
    "password": "password123"
  }')

echo "Register Response: $REGISTER_RESPONSE"
echo

# Extract token from register response (basic extraction)
TOKEN=$(echo $REGISTER_RESPONSE | grep -o '"token":"[^"]*' | cut -d'"' -f4)
echo "Extracted Token: $TOKEN"
echo

# Test 2: Login with the same user
echo "2. Logging in with the same user..."
LOGIN_RESPONSE=$(curl -s -X POST $BASE_URL/api/auth/login \
  -H "Content-Type: application/json" \
  -d '{
    "email": "testuser@example.com",
    "password": "password123"
  }')

echo "Login Response: $LOGIN_RESPONSE"
echo

# Test 3: Access user dashboard with token
echo "3. Accessing user dashboard with token..."
USER_DASHBOARD_RESPONSE=$(curl -s -X GET $BASE_URL/api/user/dashboard \
  -H "Authorization: Bearer $TOKEN")

echo "User Dashboard Response: $USER_DASHBOARD_RESPONSE"
echo

# Test 4: Try to access admin dashboard (should fail for USER role)
echo "4. Trying to access admin dashboard with USER token..."
ADMIN_DASHBOARD_RESPONSE=$(curl -s -X GET $BASE_URL/api/admin/dashboard \
  -H "Authorization: Bearer $TOKEN")

echo "Admin Dashboard Response: $ADMIN_DASHBOARD_RESPONSE"
echo

# Test 5: Try to register with same email (should fail)
echo "5. Trying to register with existing email..."
DUPLICATE_REGISTER_RESPONSE=$(curl -s -X POST $BASE_URL/api/auth/register \
  -H "Content-Type: application/json" \
  -d '{
    "name": "Another User",
    "email": "testuser@example.com",
    "password": "differentpassword"
  }')

echo "Duplicate Register Response: $DUPLICATE_REGISTER_RESPONSE"
echo

# Test 6: Try to login with wrong password
echo "6. Trying to login with wrong password..."
WRONG_PASSWORD_RESPONSE=$(curl -s -X POST $BASE_URL/api/auth/login \
  -H "Content-Type: application/json" \
  -d '{
    "email": "testuser@example.com",
    "password": "wrongpassword"
  }')

echo "Wrong Password Response: $WRONG_PASSWORD_RESPONSE"
echo

# Test 7: Try to access protected endpoint without token
echo "7. Trying to access protected endpoint without token..."
NO_TOKEN_RESPONSE=$(curl -s -X GET $BASE_URL/api/user/dashboard)

echo "No Token Response: $NO_TOKEN_RESPONSE"
echo

echo "=== Testing Complete ==="
