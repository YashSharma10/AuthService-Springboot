# JWT Authentication Service - API Testing

## Base URL
```
http://localhost:8080
```

## 1. Register a New User

### Register User (Role: USER)
```bash
curl -X POST http://localhost:8080/api/auth/register \
  -H "Content-Type: application/json" \
  -d '{
    "name": "John Doe",
    "email": "john@example.com",
    "password": "password123"
  }'
```

### Register Another User
```bash
curl -X POST http://localhost:8080/api/auth/register \
  -H "Content-Type: application/json" \
  -d '{
    "name": "Jane Smith",
    "email": "jane@example.com",
    "password": "password456"
  }'
```

**Expected Response:**
```json
{
  "token": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...",
  "role": "USER"
}
```

## 2. Login Existing User

```bash
curl -X POST http://localhost:8080/api/auth/login \
  -H "Content-Type: application/json" \
  -d '{
    "email": "john@example.com",
    "password": "password123"
  }'
```

**Expected Response:**
```json
{
  "token": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...",
  "role": "USER"
}
```

## 3. Access Protected Endpoints

### User Dashboard (Requires USER or ADMIN role)
```bash
curl -X GET http://localhost:8080/api/user/dashboard \
  -H "Authorization: Bearer YOUR_JWT_TOKEN_HERE"
```

**Expected Response:**
```
Welcome USER or ADMIN! This is the USER Dashboard.
```

### Admin Dashboard (Requires ADMIN role only)
```bash
curl -X GET http://localhost:8080/api/admin/dashboard \
  -H "Authorization: Bearer YOUR_JWT_TOKEN_HERE"
```

**Expected Response (if user has ADMIN role):**
```
Welcome ADMIN! This is the ADMIN Dashboard.
```

**Expected Response (if user has USER role):**
```json
{
  "timestamp": "2025-08-05T17:07:00.000+00:00",
  "status": 403,
  "error": "Forbidden",
  "path": "/api/admin/dashboard"
}
```

## 4. Error Cases

### Try to register with existing email
```bash
curl -X POST http://localhost:8080/api/auth/register \
  -H "Content-Type: application/json" \
  -d '{
    "name": "Another John",
    "email": "john@example.com",
    "password": "differentpassword"
  }'
```

**Expected Response:**
```json
{
  "error": "Email already in use"
}
```

### Try to login with wrong credentials
```bash
curl -X POST http://localhost:8080/api/auth/login \
  -H "Content-Type: application/json" \
  -d '{
    "email": "john@example.com",
    "password": "wrongpassword"
  }'
```

**Expected Response:**
```json
{
  "error": "Invalid username or password"
}
```

### Try to access protected endpoint without token
```bash
curl -X GET http://localhost:8080/api/user/dashboard
```

**Expected Response:**
```json
{
  "timestamp": "2025-08-05T17:07:00.000+00:00",
  "status": 401,
  "error": "Unauthorized",
  "path": "/api/user/dashboard"
}
```

### Try to access protected endpoint with invalid token
```bash
curl -X GET http://localhost:8080/api/user/dashboard \
  -H "Authorization: Bearer invalid_token"
```

**Expected Response:**
```json
{
  "timestamp": "2025-08-05T17:07:00.000+00:00",
  "status": 401,
  "error": "Unauthorized",
  "path": "/api/user/dashboard"
}
```

## 5. Complete Test Flow

1. **Register a user:**
   ```bash
   curl -X POST http://localhost:8080/api/auth/register \
     -H "Content-Type: application/json" \
     -d '{"name": "Test User", "email": "test@example.com", "password": "test123"}'
   ```

2. **Copy the token from the response and use it:**
   ```bash
   # Replace YOUR_TOKEN with the actual token from step 1
   curl -X GET http://localhost:8080/api/user/dashboard \
     -H "Authorization: Bearer YOUR_TOKEN"
   ```

3. **Login with the same user:**
   ```bash
   curl -X POST http://localhost:8080/api/auth/login \
     -H "Content-Type: application/json" \
     -d '{"email": "test@example.com", "password": "test123"}'
   ```

## Notes:
- Replace `YOUR_JWT_TOKEN_HERE` with the actual JWT token received from login/register
- The server should be running on `http://localhost:8080`
- All users are registered with the USER role by default
- To test ADMIN endpoints, you would need to manually update a user's role in the database to ADMIN
