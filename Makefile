.PHONY: help setup test lint security_check build dev_up dev_down clean

# Default target
help:
	@echo "Available targets:"
	@echo "  setup            - Install dependencies and setup development environment"
	@echo "  test             - Run all tests"
	@echo "  test_unit        - Run unit tests only"
	@echo "  test_system      - Run system tests only"
	@echo "  lint             - Run code linting"
	@echo "  security_check   - Run security checks"
	@echo "  build            - Build Docker image for production"
	@echo "  dev_up           - Start development environment with Docker Compose"
	@echo "  dev_down         - Stop development environment"
	@echo "  dev_test         - Run tests in Docker environment"
	@echo "  clean            - Clean up development environment"
	@echo "  ci_local         - Run full CI pipeline locally"

setup:
	@echo "Setting up development environment..."
	bundle install
	bin/rails db:prepare
	bin/rails db:seed

test: test_unit test_system

test_unit:
	@echo "Running unit tests..."
	RAILS_ENV=test bin/rails db:test:prepare
	bin/rails test

test_system:
	@echo "Running system tests..."
	RAILS_ENV=test bin/rails test:system

lint:
	@echo "Running RuboCop..."
	bin/rubocop

security_check:
	@echo "Running security checks..."
	bin/brakeman --no-pager
	bin/importmap audit

build:
	@echo "Building production Docker image..."
	docker build -t learn-with-me:latest .

dev_up:
	@echo "Starting development environment..."
	docker-compose up -d
	@echo "Application will be available at http://localhost:3000"

dev_down:
	@echo "Stopping development environment..."
	docker-compose down

dev_test:
	@echo "Running tests in Docker environment..."
	docker-compose --profile test run --rm test

clean:
	@echo "Cleaning up development environment..."
	docker-compose down -v
	docker system prune -f

ci_local: lint security_check test
	@echo "✅ Local CI pipeline completed successfully!"

# Docker helpers
docker_shell:
	@echo "Opening shell in web container..."
	docker-compose exec web bash

docker_logs:
	@echo "Showing logs from web container..."
	docker-compose logs -f web

# Database helpers
db_reset:
	@echo "Resetting database..."
	bin/rails db:drop db:create db:migrate db:seed

db_migrate:
	@echo "Running database migrations..."
	bin/rails db:migrate

db_seed:
	@echo "Seeding database..."
	bin/rails db:seed

