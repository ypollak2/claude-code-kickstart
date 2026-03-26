# Project Instructions

## Stack
Go 1.22, Chi/Gin router, GORM/SQLx, PostgreSQL

## Commands
- `go run ./cmd/server` — start dev server
- `go test ./...` — run all tests
- `go test -race ./...` — run tests with race detector
- `go vet ./...` — static analysis
- `golangci-lint run` — comprehensive linting
- `go mod tidy` — clean up go.mod

## Architecture
- `cmd/` — application entry points
- `internal/` — private application code
  - `api/` — HTTP handlers and middleware
  - `domain/` — business logic and interfaces
  - `repository/` — data access implementations
  - `service/` — application services
- `pkg/` — public reusable packages
- `migrations/` — database migrations

## Critical Constraints
- context.Context is always the first parameter in public functions
- Always check errors — never use `_` for error returns
- Use interfaces at the consumer, not the provider (accept interfaces, return structs)
- No `init()` functions with side effects
- Goroutines must have cancellation via context
- Use `defer` for cleanup (Close, Unlock, etc.)
- Table-driven tests are the standard pattern
