@echo off
echo ============================================
echo  AuthService API Testing Script
echo ============================================
echo.

set BASE_URL=http://localhost:8081

echo Testing AuthService endpoints...
echo Base URL: %BASE_URL%
echo.

:: Test 1: Health Check
echo 1. Testing Health Check...
curl.exe -s -w "Status Code: %%{http_code}\n" %BASE_URL%/actuator/health
echo.

:: Test 2: Public Endpoint (if exists)
echo 2. Testing Public Endpoint...
curl.exe -s -w "Status Code: %%{http_code}\n" %BASE_URL%/api/test/public 2>nul
if %ERRORLEVEL% NEQ 0 (
    echo ❌ Public endpoint not available or service not running
)
echo.

:: Test 3: User Registration
echo 3. Testing User Registration...
echo Request: POST /api/auth/register
curl.exe -X POST %BASE_URL%/api/auth/register ^
  -H "Content-Type: application/json" ^
  -d "{\"username\":\"testuser\",\"email\":\"testuser@example.com\",\"password\":\"password123\"}" ^
  -w "\nStatus Code: %%{http_code}\n"
echo.

:: Test 4: Admin Registration
echo 4. Testing Admin Registration...
echo Request: POST /api/auth/register-admin
curl.exe -X POST %BASE_URL%/api/auth/register-admin ^
  -H "Content-Type: application/json" ^
  -d "{\"username\":\"testadmin\",\"email\":\"testadmin@example.com\",\"password\":\"password123\"}" ^
  -w "\nStatus Code: %%{http_code}\n"
echo.

:: Test 5: Login with Default Admin
echo 5. Testing Login with Default Admin...
echo Request: POST /api/auth/login (admin/admin123)
for /f "tokens=*" %%i in ('curl.exe -s -X POST %BASE_URL%/api/auth/login -H "Content-Type: application/json" -d "{\"username\":\"admin\",\"password\":\"admin123\"}"') do set LOGIN_RESPONSE=%%i
echo Response: %LOGIN_RESPONSE%

:: Extract token (simplified - in real scenario you'd use jq or PowerShell)
echo Extracting JWT token...
for /f "tokens=2 delims=:" %%a in ('echo %LOGIN_RESPONSE% ^| findstr /C:"token"') do (
    for /f "tokens=1 delims=," %%b in ("%%a") do (
        set TOKEN=%%b
        set TOKEN=!TOKEN:"=!
        set TOKEN=!TOKEN: =!
    )
)
echo Token extracted (first 50 chars): !TOKEN:~0,50!...
echo.

:: Test 6: Login with Test User
echo 6. Testing Login with Test User...
echo Request: POST /api/auth/login (testuser/password123)
curl.exe -X POST %BASE_URL%/api/auth/login ^
  -H "Content-Type: application/json" ^
  -d "{\"username\":\"testuser\",\"password\":\"password123\"}" ^
  -w "\nStatus Code: %%{http_code}\n"
echo.

:: Test 7: Invalid Login
echo 7. Testing Invalid Login...
echo Request: POST /api/auth/login (invalid credentials)
curl.exe -X POST %BASE_URL%/api/auth/login ^
  -H "Content-Type: application/json" ^
  -d "{\"username\":\"invalid\",\"password\":\"wrong\"}" ^
  -w "\nStatus Code: %%{http_code}\n"
echo.

:: Test 8: Protected User Endpoint (if exists)
if defined TOKEN (
    echo 8. Testing Protected User Endpoint...
    echo Request: GET /api/test/user (with JWT token)
    curl.exe -X GET %BASE_URL%/api/test/user ^
      -H "Authorization: Bearer !TOKEN!" ^
      -w "\nStatus Code: %%{http_code}\n"
    echo.
    
    echo 9. Testing Protected Admin Endpoint...
    echo Request: GET /api/test/admin (with JWT token)
    curl.exe -X GET %BASE_URL%/api/test/admin ^
      -H "Authorization: Bearer !TOKEN!" ^
      -w "\nStatus Code: %%{http_code}\n"
    echo.
) else (
    echo 8. Skipping protected endpoint tests (no token available)
)

echo ============================================
echo  AuthService Testing Complete!
echo ============================================
echo.
echo Expected Results:
echo - Health Check: 200 OK
echo - User Registration: 200/201 Created
echo - Admin Registration: 200/201 Created  
echo - Valid Login: 200 OK with JWT token
echo - Invalid Login: 401 Unauthorized
echo - Protected Endpoints: 200 OK with valid token
echo.
pause
