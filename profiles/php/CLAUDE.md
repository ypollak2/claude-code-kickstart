# Project Instructions

## Stack
PHP 8.3, Laravel 11, PostgreSQL, Eloquent ORM, PHPUnit/Pest

## Commands
- `php artisan serve` — start dev server
- `php artisan test` — run tests
- `composer install` — install dependencies
- `php artisan migrate` — run migrations
- `php artisan make:model ModelName -mfc` — create model with migration, factory, controller
- `./vendor/bin/pint` — format code (Laravel Pint)
- `./vendor/bin/phpstan analyse` — static analysis

## Architecture
- `app/`
  - `Http/Controllers/` — request handlers
  - `Http/Requests/` — form request validation
  - `Http/Resources/` — API resource transformers
  - `Models/` — Eloquent models
  - `Services/` — business logic
  - `Repositories/` — data access layer (optional)
  - `Events/` & `Listeners/` — event system
  - `Jobs/` — queued jobs
- `routes/` — web.php, api.php
- `database/migrations/` — database migrations
- `database/factories/` — model factories for testing
- `tests/` — Feature/ and Unit/ directories
- `resources/views/` — Blade templates

## Critical Constraints
- Use Form Request classes for validation, never validate in controllers
- Use API Resources for response transformation, never return models directly
- Use Eloquent relationships and eager loading to avoid N+1 queries
- Never use raw SQL without parameter binding
- Queue long-running operations, never block HTTP requests
- Use Laravel's built-in auth, don't roll your own
