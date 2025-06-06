# CI/CD Pipeline Documentation

## Overview

This document describes the CI/CD pipeline setup for the "Learn With Me" Rails application. The pipeline uses GitHub Actions for continuous integration and supports multiple deployment strategies.

## Pipeline Structure

### Continuous Integration (CI)

The CI pipeline runs on:
- Pull requests to any branch
- Pushes to `main` and `develop` branches
- Manual workflow dispatch

#### Jobs

1. **Changes Detection** - Determines which parts of the codebase changed to optimize pipeline execution
2. **Security Scan** - Runs Brakeman for Ruby security vulnerabilities
3. **JavaScript Security Scan** - Audits JavaScript dependencies
4. **Lint** - Runs RuboCop for code style consistency
5. **Test** - Executes unit and system tests with PostgreSQL and Redis
6. **Build Docker** - Builds and pushes Docker images for deployment

### Continuous Deployment (CD)

- **Staging**: Automatically deploys `develop` branch
- **Production**: Automatically deploys `main` branch
- **Manual**: Deploy to any environment via workflow dispatch

## Prerequisites

### GitHub Repository Secrets

Set up the following secrets in your GitHub repository:

```bash
# Docker Hub credentials
DOCKER_USERNAME=your-docker-username
DOCKER_PASSWORD=your-docker-password

# Database credentials
POSTGRES_USER=postgres
POSTGRES_PASSWORD=your-postgres-password

# Rails secrets
RAILS_MASTER_KEY=your-master-key
SECRET_KEY_BASE=your-secret-key-base

# Deployment credentials (if using Kamal)
KAMAL_REGISTRY_PASSWORD=your-registry-password
```

### Environment Setup

1. Copy environment template:
   ```bash
   cp .env.example .env
   ```

2. Fill in your environment variables in `.env`

## Local Development with Docker

### Quick Start

```bash
# Start development environment
make dev_up

# Run tests
make dev_test

# Stop environment
make dev_down
```

### Manual Docker Commands

```bash
# Start all services
docker-compose up -d

# Run tests in isolated environment
docker-compose --profile test run --rm test

# Access application shell
docker-compose exec web bash

# View logs
docker-compose logs -f web

# Stop and clean up
docker-compose down -v
```

## Running CI Pipeline Locally

```bash
# Run complete CI pipeline
make ci_local

# Or run individual steps
make lint
make security_check
make test
```

## Deployment

### Using Kamal (Recommended)

1. Set up deployment configuration:
   ```bash
   cp config/deploy.yml.example config/deploy.yml
   ```

2. Edit `config/deploy.yml` with your server details

3. Deploy:
   ```bash
   # Initial setup
   kamal setup
   
   # Regular deployments
   kamal deploy
   ```

### Manual Deployment

The pipeline builds and pushes Docker images to Docker Hub. You can pull and run these images on any Docker-compatible platform:

```bash
# Pull latest image
docker pull your-username/learn-with-me:latest

# Run with required environment variables
docker run -d \
  -p 80:80 \
  -e RAILS_MASTER_KEY=your-master-key \
  -e DATABASE_URL=your-database-url \
  your-username/learn-with-me:latest
```

## Pipeline Optimization

### Smart Change Detection

The pipeline uses path filters to run only necessary jobs:
- Backend changes trigger Ruby tests and security scans
- Frontend changes trigger JavaScript audits
- Docker changes trigger image rebuilds

### Caching

- **Ruby gems**: Cached using `ruby/setup-ruby` action
- **Docker layers**: Cached using GitHub Actions cache
- **Database**: PostgreSQL service runs with health checks

## Monitoring and Notifications

### Pipeline Status

- GitHub Actions provides built-in status checks
- Failed builds prevent merging (if branch protection is enabled)
- Deployment status is reported to GitHub environments

### Artifacts

- Security scan reports (Brakeman, RuboCop)
- Test coverage reports
- System test screenshots (on failure)

## Troubleshooting

### Common Issues

1. **PostgreSQL connection failures**:
   - Ensure health checks pass before running tests
   - Verify environment variables are correctly set

2. **Docker build failures**:
   - Check Dockerfile syntax
   - Ensure all required dependencies are included

3. **Test failures**:
   - Review test logs in GitHub Actions
   - Download system test screenshots for debugging

### Debug Commands

```bash
# Check CI pipeline locally
make ci_local

# Inspect Docker environment
docker-compose ps
docker-compose logs web

# Access application console
docker-compose exec web bin/rails console
```

## Security Considerations

- All secrets are stored in GitHub Secrets (encrypted)
- Docker images are scanned for vulnerabilities
- Dependencies are regularly audited
- Production deploys require environment approval (configurable)

## Performance

- Parallel job execution reduces pipeline time
- Smart change detection skips unnecessary work
- Docker layer caching speeds up builds
- Database initialization is optimized with health checks

## Contributing

When adding new features:
1. Ensure tests pass locally with `make test`
2. Run security checks with `make security_check`
3. Verify Docker builds work with `make build`
4. Update this documentation if pipeline changes

