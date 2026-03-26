# Project Instructions

## Stack
Java 21, Spring Boot 3, PostgreSQL, Maven/Gradle, JUnit 5

## Commands
- `./mvnw spring-boot:run` — start dev server
- `./mvnw test` — run tests
- `./mvnw package` — build JAR
- `./mvnw spotless:check` — check formatting
- `./mvnw spotless:apply` — fix formatting

## Architecture
- `src/main/java/com/example/`
  - `controller/` — REST controllers
  - `service/` — business logic (interfaces + implementations)
  - `repository/` — Spring Data JPA repositories
  - `model/` — JPA entities
  - `dto/` — request/response DTOs
  - `config/` — Spring configuration
  - `exception/` — custom exceptions and global handler
- `src/main/resources/`
  - `application.yml` — configuration
  - `db/migration/` — Flyway migrations
- `src/test/` — mirrors main structure

## Critical Constraints
- Use constructor injection, never field injection (@Autowired on fields)
- DTOs for API boundaries, entities for persistence — never expose entities in APIs
- All public service methods must be transactional where appropriate
- Use Optional return types, never return null from repository methods
- Custom exceptions must extend a base ApplicationException
- Validate all incoming DTOs with @Valid and Jakarta validation annotations
