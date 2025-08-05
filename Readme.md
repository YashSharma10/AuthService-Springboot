# SpringBoot Authentication Service

A secure JWT-based authentication service with role-based access control.

## 🚀 Quick Start

### Prerequisites

- Java 17+, Maven 3.6+, MySQL 8.0+

### Setup & Run

1. Configure database in `src/main/resources/application.properties`
2. Run: `mvn spring-boot:run`
3. Application starts on: `http://localhost:8080`

## Key Features

- ✅ **JWT Authentication** - Secure token-based auth
- ✅ **Default USER Role** - All registrations default to USER
- ✅ **Admin Endpoint** - Dedicated `/api/auth/register-admin` for admins
- ✅ **Role-Based Access** - USER and ADMIN permissions
- ✅ **Spring Security** - Modern security configuration

## 📋 API Endpoints

| Endpoint                     | Method | Access    | Role  |
| ---------------------------- | ------ | --------- | ----- |
| `/api/auth/register`       | POST   | Public    | USER  |
| `/api/auth/register-admin` | POST   | Public*   | ADMIN |
| `/api/auth/login`          | POST   | Public    | -     |
| `/api/test/public`         | GET    | Public    | -     |
| `/api/test/user`           | GET    | Protected | USER+ |
| `/api/test/admin`          | GET    | Protected | ADMIN |

*Should be secured in production

## 📚 Documentation

- **[Complete Guide](documentation/COMPLETE-GUIDE.md)** - Full documentation and setup
- **[API Testing Commands](documentation/API-TESTING-COMMANDS.txt)** - Curl commands & Postman setup
- **[Test Script](documentation/test-all-endpoints.cmd)** - Automated testing

## 🧪 Quick Test

```bash
# Automated testing
cd documentation
./test-all-endpoints.cmd

# Manual testing - see API-TESTING-COMMANDS.txt for all curl commands
curl -X GET http://localhost:8080/api/test/public
```

## 🎯 Status: ✅ PRODUCTION READY

All requirements implemented and tested:

- Default USER role assignment ✅
- Admin endpoint creation ✅
- JWT authentication ✅
- Role-based access control ✅
