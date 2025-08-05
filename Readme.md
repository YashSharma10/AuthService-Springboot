# JWT Authentication Service - Complete Project Documentation

## Table of Contents
1. [Project Overview](#project-overview)
2. [Architecture & Design Patterns](#architecture--design-patterns)
3. [Technology Stack](#technology-stack)
4. [Project Structure](#project-structure)
5. [Core Components Detailed Analysis](#core-components-detailed-analysis)
6. [Database Design](#database-design)
7. [Security Implementation](#security-implementation)
8. [JWT Token Flow](#jwt-token-flow)
9. [API Endpoints](#api-endpoints)
10. [Configuration Files](#configuration-files)
11. [Error Handling](#error-handling)
12. [Application Flow](#application-flow)
13. [Deployment & Testing](#deployment--testing)

---

## 1. Project Overview

### Purpose
This is a **Spring Boot-based JWT Authentication Microservice** that provides:
- User registration and login functionality
- Role-based access control (RBAC)
- Stateless authentication using JWT tokens
- RESTful API endpoints for authentication
- MySQL database integration for persistent storage

### Key Features
- ✅ JWT-based stateless authentication
- ✅ Role-based authorization (USER, ADMIN)
- ✅ Password encryption using BCrypt
- ✅ MySQL database integration with JPA/Hibernate
- ✅ Global exception handling
- ✅ Security filter chain implementation
- ✅ Automatic role initialization

---

## 2. Architecture & Design Patterns

### Architectural Patterns Used

#### 1. **Layered Architecture (N-Tier)**
```
┌─────────────────┐
│   Controller    │ ← REST API Layer
├─────────────────┤
│    Service      │ ← Business Logic Layer
├─────────────────┤
│   Repository    │ ← Data Access Layer
├─────────────────┤
│    Database     │ ← Persistence Layer
└─────────────────┘
```

#### 2. **MVC Pattern (Model-View-Controller)**
- **Model**: Entity classes (User, Role)
- **View**: JSON responses (DTOs)
- **Controller**: REST controllers handling HTTP requests

#### 3. **Dependency Injection**
- Uses Spring's IoC container for managing bean dependencies
- Constructor injection pattern for better testability

#### 4. **Repository Pattern**
- JPA repositories abstract database operations
- Provides consistent data access interface

#### 5. **Filter Chain Pattern**
- JWT authentication filter intercepts requests
- Spring Security filter chain processes authentication

---

## 3. Technology Stack

### Backend Framework
- **Spring Boot 3.5.4**: Main application framework
- **Spring Security 6.x**: Authentication and authorization
- **Spring Data JPA**: Data persistence and ORM
- **Spring Web**: RESTful web services

### Database
- **MySQL 8.0**: Primary database
- **Hibernate 6.6.22**: ORM implementation
- **HikariCP**: Connection pooling

### Security & JWT
- **JJWT (JsonWebToken) 0.11.5**: JWT token creation and validation
- **BCrypt**: Password hashing algorithm

### Build Tool
- **Maven**: Dependency management and build automation

### Java Version
- **Java 17**: Runtime environment

---

## 4. Project Structure

```
authservice/
├── src/
│   ├── main/
│   │   ├── java/com/example/authservice/
│   │   │   ├── AuthserviceApplication.java     # Main Spring Boot class
│   │   │   ├── config/                         # Configuration classes
│   │   │   │   ├── SecurityConfig.java         # Security configuration
│   │   │   │   ├── JwtTokenFilter.java         # JWT authentication filter
│   │   │   │   └── DataInitializer.java        # Database initialization
│   │   │   ├── controller/                     # REST controllers
│   │   │   │   ├── AuthController.java         # Authentication endpoints
│   │   │   │   └── TestController.java         # Protected test endpoints
│   │   │   ├── dto/                           # Data Transfer Objects
│   │   │   │   ├── AuthRequest.java           # Login request DTO
│   │   │   │   ├── AuthResponse.java          # Authentication response DTO
│   │   │   │   └── RegisterRequest.java       # Registration request DTO
│   │   │   ├── entity/                        # JPA entities
│   │   │   │   ├── User.java                  # User entity
│   │   │   │   └── Role.java                  # Role entity
│   │   │   ├── exception/                     # Exception handling
│   │   │   │   ├── GlobalExceptionHandler.java
│   │   │   │   └── UserAlreadyExistsException.java
│   │   │   ├── repository/                    # Data access layer
│   │   │   │   ├── UserRepository.java        # User data operations
│   │   │   │   └── RoleRepository.java        # Role data operations
│   │   │   ├── service/                       # Business logic layer
│   │   │   │   ├── AuthService.java           # Authentication service interface
│   │   │   │   ├── AuthServiceImpl.java       # Authentication service implementation
│   │   │   │   └── JwtService.java            # JWT token operations
│   │   │   └── util/
│   │   │       └── RoleEnum.java              # Role enumeration
│   │   └── resources/
│   │       └── application.properties         # Application configuration
│   └── test/                                  # Test classes
├── pom.xml                                    # Maven configuration
├── test-endpoints.md                          # API testing documentation
├── test-api.sh                               # Linux/Mac test script
└── test-api.bat                              # Windows test script
```

---

## 5. Core Components Detailed Analysis

### 5.1 Main Application Class

```java
@SpringBootApplication
public class AuthserviceApplication {
    public static void main(String[] args) {
        SpringApplication.run(AuthserviceApplication.class, args);
    }
}
```

**Purpose**: 
- Entry point of the Spring Boot application
- Enables auto-configuration, component scanning, and configuration

### 5.2 Entity Classes

#### User Entity
```java
@Entity
@Table(name = "users")
public class User implements UserDetails {
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;
    
    private String name;
    
    @Column(unique = true, nullable = false)
    private String email;
    
    @Column(nullable = false)
    private String password;
    
    @ManyToOne(fetch = FetchType.EAGER)
    @JoinColumn(name = "role_id", nullable = false)
    private Role role;
    
    // UserDetails implementation methods...
}
```

**Key Features**:
- Implements `UserDetails` for Spring Security integration
- Maps to "users" table in database
- Email field has unique constraint
- Many-to-One relationship with Role entity
- Eager fetching for role data

**UserDetails Methods**:
- `getAuthorities()`: Returns user roles as Spring Security authorities
- `getUsername()`: Returns email as username
- `isAccountNonExpired()`: Account validity checks
- `isEnabled()`: User activation status

#### Role Entity
```java
@Entity
@Table(name = "roles")
public class Role {
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;
    
    @Enumerated(EnumType.STRING)
    @Column(length = 20, unique = true, nullable = false)
    private RoleEnum name;
}
```

**Key Features**:
- Maps to "roles" table
- Uses enum for type safety
- Unique constraint on role name
- Auto-generated primary key

### 5.3 Data Transfer Objects (DTOs)

#### AuthRequest (Login)
```java
public class AuthRequest {
    private String email;
    private String password;
}
```

#### RegisterRequest
```java
public class RegisterRequest {
    private String name;
    private String email;
    private String password;
}
```

#### AuthResponse
```java
public class AuthResponse {
    private String token;
    private String role;
}
```

**Purpose**: 
- Separate data transfer from entity structure
- Provide clean API contracts
- Avoid exposing internal entity structure

### 5.4 Repository Layer

#### UserRepository
```java
public interface UserRepository extends JpaRepository<User, Long> {
    Optional<User> findByEmail(String email);
    boolean existsByEmail(String email);
}
```

#### RoleRepository
```java
public interface RoleRepository extends JpaRepository<Role, Long> {
    Optional<Role> findByName(RoleEnum name);
}
```

**Features**:
- Extend JpaRepository for CRUD operations
- Custom query methods using method naming conventions
- Return Optional types for null safety

### 5.5 Service Layer

#### JwtService
```java
@Service
public class JwtService {
    @Value("${jwt.secret}")
    private String secret;
    
    @Value("${jwt.expiration}")
    private long jwtExpirationMs;
    
    public String generateToken(UserDetails userDetails) {
        return Jwts.builder()
                .setSubject(userDetails.getUsername())
                .setIssuedAt(new Date())
                .setExpiration(new Date(System.currentTimeMillis() + jwtExpirationMs))
                .signWith(getSignInKey(), SignatureAlgorithm.HS256)
                .compact();
    }
    
    public boolean isTokenValid(String token, UserDetails userDetails) {
        final String username = extractUsername(token);
        return (username.equals(userDetails.getUsername())) && !isTokenExpired(token);
    }
}
```

**Key Responsibilities**:
- JWT token generation and validation
- Token expiration handling
- Claims extraction from tokens
- HMAC-SHA256 signing algorithm

#### AuthServiceImpl
```java
@Service
public class AuthServiceImpl implements AuthService {
    
    public AuthResponse register(RegisterRequest request) {
        // 1. Check if email already exists
        if (userRepository.existsByEmail(request.getEmail())) {
            throw new UserAlreadyExistsException("Email already in use");
        }
        
        // 2. Get default USER role
        Role defaultRole = roleRepository.findByName(RoleEnum.USER)
                .orElseThrow(() -> new RuntimeException("Default role USER not found"));
        
        // 3. Create new user with encrypted password
        User user = new User(
                request.getName(),
                request.getEmail(),
                passwordEncoder.encode(request.getPassword()),
                defaultRole
        );
        
        // 4. Save user to database
        userRepository.save(user);
        
        // 5. Generate JWT token
        String token = jwtService.generateToken(user);
        
        // 6. Return response with token and role
        return new AuthResponse(token, user.getRole().getName().name());
    }
    
    public AuthResponse login(AuthRequest request) {
        // 1. Authenticate user credentials
        authenticationManager.authenticate(
                new UsernamePasswordAuthenticationToken(request.getEmail(), request.getPassword())
        );
        
        // 2. Retrieve user from database
        User user = userRepository.findByEmail(request.getEmail())
                .orElseThrow(() -> new RuntimeException("User not found"));
        
        // 3. Generate JWT token
        String token = jwtService.generateToken(user);
        
        // 4. Return response with token and role
        return new AuthResponse(token, user.getRole().getName().name());
    }
}
```

**Key Responsibilities**:
- User registration logic
- User authentication logic
- Password encryption
- JWT token generation
- Business rule validation

### 5.6 Controller Layer

#### AuthController
```java
@RestController
@RequestMapping("/api/auth")
public class AuthController {
    
    @PostMapping("/register")
    public ResponseEntity<AuthResponse> register(@RequestBody RegisterRequest request) {
        return ResponseEntity.ok(authService.register(request));
    }
    
    @PostMapping("/login")
    public ResponseEntity<AuthResponse> login(@RequestBody AuthRequest request) {
        return ResponseEntity.ok(authService.login(request));
    }
}
```

#### TestController
```java
@RestController
@RequestMapping("/api")
public class TestController {
    
    @GetMapping("/user/dashboard")
    @PreAuthorize("hasRole('USER') or hasRole('ADMIN')")
    public String userAccess() {
        return "Welcome USER or ADMIN! This is the USER Dashboard.";
    }
    
    @GetMapping("/admin/dashboard")
    @PreAuthorize("hasRole('ADMIN')")
    public String adminAccess() {
        return "Welcome ADMIN! This is the ADMIN Dashboard.";
    }
}
```

**Key Features**:
- RESTful endpoint design
- HTTP status code handling
- Request/Response body mapping
- Method-level security annotations

---

## 6. Database Design

### Entity Relationship Diagram

```
┌─────────────────┐       ┌─────────────────┐
│      roles      │       │      users      │
├─────────────────┤       ├─────────────────┤
│ id (PK)         │◄──────┤ id (PK)         │
│ name (UNIQUE)   │       │ name            │
└─────────────────┘       │ email (UNIQUE)  │
                          │ password        │
                          │ role_id (FK)    │
                          └─────────────────┘
```

### Database Tables

#### roles table
```sql
CREATE TABLE roles (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(20) UNIQUE NOT NULL
);
```

#### users table
```sql
CREATE TABLE users (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(255),
    email VARCHAR(255) UNIQUE NOT NULL,
    password VARCHAR(255) NOT NULL,
    role_id BIGINT NOT NULL,
    FOREIGN KEY (role_id) REFERENCES roles(id)
);
```

### Data Relationships
- **One-to-Many**: Role → Users (One role can have many users)
- **Many-to-One**: User → Role (Many users belong to one role)

---

## 7. Security Implementation

### 7.1 Security Configuration

```java
@Configuration
@EnableMethodSecurity
public class SecurityConfig {
    
    @Bean
    public SecurityFilterChain securityFilterChain(HttpSecurity http, JwtTokenFilter jwtTokenFilter) throws Exception {
        return http
            .csrf(csrf -> csrf.disable())                          // Disable CSRF for stateless API
            .authorizeHttpRequests(auth -> auth
                .requestMatchers("/api/auth/**").permitAll()        // Allow public access to auth endpoints
                .requestMatchers(HttpMethod.GET, "/admin/**").hasRole("ADMIN")  // Admin-only endpoints
                .requestMatchers(HttpMethod.GET, "/user/**").hasAnyRole("USER", "ADMIN")  // User/Admin endpoints
                .anyRequest().authenticated()                       // All other requests require authentication
            )
            .sessionManagement(session -> session.sessionCreationPolicy(SessionCreationPolicy.STATELESS))  // Stateless sessions
            .exceptionHandling(ex -> ex
                .authenticationEntryPoint((request, response, authException) -> 
                    response.sendError(HttpServletResponse.SC_UNAUTHORIZED, authException.getMessage())
                )
            )
            .addFilterBefore(jwtTokenFilter, UsernamePasswordAuthenticationFilter.class)  // Add JWT filter
            .build();
    }
}
```

### 7.2 JWT Authentication Filter

```java
@Component
public class JwtTokenFilter extends OncePerRequestFilter {
    
    @Override
    protected void doFilterInternal(
        HttpServletRequest request,
        HttpServletResponse response,
        FilterChain filterChain
    ) throws ServletException, IOException {
        
        // 1. Extract Authorization header
        final String authHeader = request.getHeader("Authorization");
        
        // 2. Check if header exists and starts with "Bearer "
        if (authHeader == null || !authHeader.startsWith("Bearer ")) {
            filterChain.doFilter(request, response);
            return;
        }
        
        // 3. Extract JWT token
        final String jwt = authHeader.substring(7);
        final String username = jwtService.extractUsername(jwt);
        
        // 4. Validate token and set authentication
        if (username != null && SecurityContextHolder.getContext().getAuthentication() == null) {
            UserDetails userDetails = userDetailsService.loadUserByUsername(username);
            
            if (jwtService.isTokenValid(jwt, userDetails)) {
                UsernamePasswordAuthenticationToken authToken = new UsernamePasswordAuthenticationToken(
                    userDetails, null, userDetails.getAuthorities()
                );
                authToken.setDetails(new WebAuthenticationDetailsSource().buildDetails(request));
                SecurityContextHolder.getContext().setAuthentication(authToken);
            }
        }
        
        filterChain.doFilter(request, response);
    }
}
```

### 7.3 Password Encryption

```java
@Bean
public BCryptPasswordEncoder passwordEncoder() {
    return new BCryptPasswordEncoder();
}
```

**BCrypt Features**:
- Adaptive hashing function
- Built-in salt generation
- Configurable work factor
- Resistance to rainbow table attacks

---

## 8. JWT Token Flow

### Token Generation Process

```
Registration/Login Request
         ↓
1. Validate Credentials
         ↓
2. Create JWT Claims
   - Subject (username/email)
   - Issued At (timestamp)
   - Expiration (timestamp)
         ↓
3. Sign Token with Secret Key
   - Algorithm: HMAC-SHA256
   - Secret: Configured in properties
         ↓
4. Return Signed JWT Token
```

### Token Validation Process

```
Incoming Request with JWT
         ↓
1. Extract "Authorization" Header
         ↓
2. Remove "Bearer " Prefix
         ↓
3. Parse JWT Token
         ↓
4. Verify Signature
         ↓
5. Check Expiration
         ↓
6. Extract Username/Claims
         ↓
7. Load UserDetails
         ↓
8. Set Authentication Context
         ↓
9. Continue Filter Chain
```

### JWT Token Structure

```
Header.Payload.Signature

Header:
{
  "alg": "HS256",
  "typ": "JWT"
}

Payload:
{
  "sub": "user@example.com",
  "iat": 1691234567,
  "exp": 1691320967
}

Signature:
HMACSHA256(
  base64UrlEncode(header) + "." +
  base64UrlEncode(payload),
  secret
)
```

---

## 9. API Endpoints

### Authentication Endpoints

#### POST /api/auth/register
**Purpose**: Register a new user
**Request Body**:
```json
{
  "name": "John Doe",
  "email": "john@example.com",
  "password": "password123"
}
```
**Response**:
```json
{
  "token": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...",
  "role": "USER"
}
```
**HTTP Status**: 200 OK (success), 409 Conflict (email exists)

#### POST /api/auth/login
**Purpose**: Authenticate existing user
**Request Body**:
```json
{
  "email": "john@example.com",
  "password": "password123"
}
```
**Response**:
```json
{
  "token": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...",
  "role": "USER"
}
```
**HTTP Status**: 200 OK (success), 401 Unauthorized (invalid credentials)

### Protected Endpoints

#### GET /api/user/dashboard
**Purpose**: User dashboard access
**Authorization**: Bearer token required
**Roles**: USER, ADMIN
**Response**: Plain text message

#### GET /api/admin/dashboard
**Purpose**: Admin dashboard access
**Authorization**: Bearer token required
**Roles**: ADMIN only
**Response**: Plain text message

---

## 10. Configuration Files

### application.properties
```properties
# Application Configuration
spring.application.name=authservice

# JWT Configuration
jwt.secret=your_super_secret_key_which_is_at_least_32_characters
jwt.expiration=86400000

# Database Configuration
spring.datasource.url=jdbc:mysql://localhost:3306/jwt_auth
spring.datasource.username=root
spring.datasource.password=your_password

# JPA/Hibernate Configuration
spring.jpa.hibernate.ddl-auto=update
spring.jpa.show-sql=true
```

### pom.xml Dependencies
```xml
<!-- Spring Boot Starters -->
<dependency>
    <groupId>org.springframework.boot</groupId>
    <artifactId>spring-boot-starter-web</artifactId>
</dependency>
<dependency>
    <groupId>org.springframework.boot</groupId>
    <artifactId>spring-boot-starter-security</artifactId>
</dependency>
<dependency>
    <groupId>org.springframework.boot</groupId>
    <artifactId>spring-boot-starter-data-jpa</artifactId>
</dependency>

<!-- Database Driver -->
<dependency>
    <groupId>com.mysql</groupId>
    <artifactId>mysql-connector-j</artifactId>
</dependency>

<!-- JWT Library -->
<dependency>
    <groupId>io.jsonwebtoken</groupId>
    <artifactId>jjwt-api</artifactId>
    <version>0.11.5</version>
</dependency>
```

---

## 11. Error Handling

### Global Exception Handler

```java
@RestControllerAdvice
public class GlobalExceptionHandler {
    
    @ExceptionHandler(BadCredentialsException.class)
    public ResponseEntity<Map<String, String>> handleBadCredentials(BadCredentialsException ex) {
        Map<String, String> response = new HashMap<>();
        response.put("error", "Invalid username or password");
        return new ResponseEntity<>(response, HttpStatus.UNAUTHORIZED);
    }
    
    @ExceptionHandler(UserAlreadyExistsException.class)
    public ResponseEntity<Map<String, String>> handleUserAlreadyExists(UserAlreadyExistsException ex) {
        Map<String, String> response = new HashMap<>();
        response.put("error", ex.getMessage());
        return new ResponseEntity<>(response, HttpStatus.CONFLICT);
    }
}
```

### Exception Types Handled

1. **BadCredentialsException**: Invalid login credentials
2. **UserAlreadyExistsException**: Duplicate email registration
3. **MethodArgumentNotValidException**: Request validation errors
4. **General Exception**: Catch-all for unexpected errors

---

## 12. Application Flow

### Startup Flow

```
1. Spring Boot Application Starts
         ↓
2. Auto-configuration Activated
         ↓
3. Database Connection Established
         ↓
4. JPA Entities Mapped to Tables
         ↓
5. DataInitializer Runs
   - Creates USER role if not exists
   - Creates ADMIN role if not exists
         ↓
6. Security Configuration Applied
         ↓
7. JWT Filter Registered
         ↓
8. Controllers Mapped to Endpoints
         ↓
9. Application Ready on Port 8080
```

### Request Processing Flow

#### Registration Flow
```
POST /api/auth/register
         ↓
AuthController.register()
         ↓
AuthServiceImpl.register()
         ↓
1. Check email uniqueness
2. Get default USER role
3. Encrypt password
4. Save user to database
5. Generate JWT token
         ↓
Return AuthResponse with token
```

#### Login Flow
```
POST /api/auth/login
         ↓
AuthController.login()
         ↓
AuthServiceImpl.login()
         ↓
1. Authenticate credentials
2. Load user from database
3. Generate JWT token
         ↓
Return AuthResponse with token
```

#### Protected Endpoint Access Flow
```
GET /api/user/dashboard
         ↓
JwtTokenFilter.doFilterInternal()
         ↓
1. Extract Authorization header
2. Validate JWT token
3. Load user details
4. Set security context
         ↓
TestController.userAccess()
         ↓
@PreAuthorize check
         ↓
Return dashboard content
```

---

## 13. Deployment & Testing

### Running the Application

1. **Prerequisites**:
   - Java 17 or higher
   - Maven 3.6+
   - MySQL 8.0+

2. **Database Setup**:
   ```sql
   CREATE DATABASE jwt_auth;
   ```

3. **Start Application**:
   ```bash
   mvn spring-boot:run
   ```

4. **Verify Startup**:
   - Application runs on http://localhost:8080
   - Database tables created automatically
   - Default roles (USER, ADMIN) initialized

### Testing Strategy

1. **Unit Testing**:
   - Service layer methods
   - Repository operations
   - JWT token operations

2. **Integration Testing**:
   - Controller endpoints
   - Security filter chain
   - Database operations

3. **API Testing**:
   - Use provided curl commands
   - Test registration/login flow
   - Verify protected endpoint access
   - Test error scenarios

### Performance Considerations

1. **Database Optimization**:
   - Index on email column for fast lookups
   - Connection pooling with HikariCP
   - Eager loading for roles (small dataset)

2. **Security Optimization**:
   - Stateless authentication (no server-side sessions)
   - JWT tokens reduce database calls
   - BCrypt work factor balances security/performance

3. **Memory Management**:
   - No session storage required
   - Minimal server state
   - Efficient JWT parsing

---

## Summary

This JWT authentication service provides a robust, scalable solution for user authentication and authorization. Key strengths include:

- **Security**: Industry-standard JWT implementation with BCrypt password hashing
- **Scalability**: Stateless architecture supports horizontal scaling
- **Maintainability**: Clean layered architecture with separation of concerns
- **Flexibility**: Role-based access control extensible for complex permissions
- **Performance**: Optimized database design and connection pooling

The service follows Spring Boot best practices and modern security standards, making it suitable for production use in microservice architectures.
