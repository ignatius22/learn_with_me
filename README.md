# Learn With Me 📚

> A modern online learning platform built with Ruby on Rails, inspired by Udemy's user experience and designed for seamless course delivery and progress tracking.

[![CI/CD Pipeline](https://github.com/ignatius22/learn_with_me/actions/workflows/ci.yml/badge.svg)](https://github.com/ignatius22/learn_with_me/actions/workflows/ci.yml)
[![Ruby Version](https://img.shields.io/badge/ruby-3.4.2-red.svg)](https://www.ruby-lang.org/)
[![Rails Version](https://img.shields.io/badge/rails-8.0.2-red.svg)](https://rubyonrails.org/)
[![License](https://img.shields.io/badge/license-MIT-blue.svg)](LICENSE)

## 🌟 Features

### For Students
- **Course Discovery**: Browse and search through available courses with detailed descriptions
- **Seamless Enrollment**: One-click course enrollment with instant access
- **Interactive Learning**: Watch video lessons and read text content with progress tracking
- **Progress Tracking**: Real-time tracking of lesson completion and course progress
- **Dashboard**: Personalized learning dashboard with quick access to continue studying
- **Profile Management**: Manage personal information and learning preferences

### For Instructors
- **Course Creation**: Create comprehensive courses with multiple sections and lessons
- **Content Management**: Upload and organize video and text-based learning materials
- **Student Analytics**: Track student enrollment and progress across courses

### Platform Features
- **Responsive Design**: Fully responsive UI that works on desktop, tablet, and mobile
- **Modern UX**: Clean, intuitive interface inspired by leading e-learning platforms
- **Real-time Updates**: Hotwire integration for dynamic, SPA-like interactions
- **Secure Authentication**: User registration and login powered by Devise
- **Role-based Access**: Support for different user roles (students, instructors, admins)

## 🛠 Tech Stack

### Backend
- **Ruby 3.4.2** - Programming language
- **Rails 8.0.2** - Web application framework
- **PostgreSQL** - Primary database
- **Redis** - Caching and session storage
- **Devise** - Authentication and user management

### Frontend
- **Hotwire** (Turbo + Stimulus) - Dynamic interactions without complex JavaScript
- **Tailwind CSS** - Utility-first CSS framework for rapid UI development
- **Importmap** - Modern JavaScript module management

### Development & Deployment
- **Docker** - Containerization for consistent environments
- **GitHub Actions** - CI/CD pipeline
- **Kamal** - Production deployment
- **RuboCop** - Code quality and style enforcement
- **Brakeman** - Security vulnerability scanning

## 🚀 Quick Start

### Prerequisites
- Ruby 3.4.2
- PostgreSQL 15+
- Redis 7+
- Node.js 18+ (for asset compilation)

### Local Development Setup

1. **Clone the repository**
   ```bash
   git clone https://github.com/ignatius22/learn_with_me.git
   cd learn_with_me
   ```

2. **Install dependencies**
   ```bash
   bundle install
   ```

3. **Set up environment variables**
   ```bash
   cp .env.example .env
   # Edit .env with your database and Redis configuration
   ```

4. **Set up the database**
   ```bash
   bin/rails db:create db:migrate db:seed
   ```

5. **Start the development server**
   ```bash
   bin/rails server
   ```

6. **Visit the application**
   Open [http://localhost:3000](http://localhost:3000) in your browser

### Using Docker (Recommended)

1. **Start with Docker Compose**
   ```bash
   make dev_up
   # Or manually: docker-compose up -d
   ```

2. **Access the application**
   Open [http://localhost:3000](http://localhost:3000)

3. **Run commands in the container**
   ```bash
   docker-compose exec web bin/rails console
   docker-compose exec web bin/rails db:seed
   ```

## 📖 Usage Guide

### For Students

1. **Sign Up**: Create a new account or log in with existing credentials
2. **Browse Courses**: Explore available courses on the homepage
3. **Enroll**: Click "Enroll Now" on any course page
4. **Start Learning**: Access course content through "Start Learning" or "Continue Learning" buttons
5. **Track Progress**: Monitor your progress on the dashboard and within each course
6. **Complete Lessons**: Mark lessons as complete to track your learning journey

### For Instructors

1. **Access Admin Panel**: Navigate to instructor dashboard (role-based access)
2. **Create Courses**: Add new courses with descriptions, categories, and pricing
3. **Add Content**: Create sections and lessons with video or text content
4. **Monitor Students**: Track enrollment numbers and student progress
5. **Update Content**: Modify course materials and structure as needed

### Sample Data

The application comes with comprehensive seed data including:
- **5 Sample Courses** across different categories (Web Development, Data Science, Design, etc.)
- **15+ Lessons** with varied content types
- **User Roles** (Student, Instructor, Admin)
- **Sample Enrollments** and progress data

## 🧪 Testing

### Run Tests Locally

```bash
# Run all tests
make test
# Or: bin/rails test && bin/rails test:system

# Run specific test types
make test_unit     # Unit tests only
make test_system   # System tests only

# Run with coverage
RAILS_ENV=test bin/rails test
```

### Run Tests with Docker

```bash
# Run tests in isolated Docker environment
make dev_test
# Or: docker-compose --profile test run --rm test
```

### Code Quality Checks

```bash
# Run linting
make lint
# Or: bin/rubocop

# Run security scan
make security_check
# Or: bin/brakeman --no-pager

# Run complete CI pipeline locally
make ci_local
```

## 🚢 Deployment

### Using Kamal (Recommended)

1. **Set up deployment configuration**
   ```bash
   cp config/deploy.yml.example config/deploy.yml
   # Edit with your server details
   ```

2. **Deploy to production**
   ```bash
   # Initial setup
   kamal setup
   
   # Regular deployments
   kamal deploy
   ```

### Using Docker

```bash
# Build production image
make build
# Or: docker build -t learn-with-me .

# Run in production
docker run -d \
  -p 80:80 \
  -e RAILS_MASTER_KEY=your-master-key \
  -e DATABASE_URL=your-database-url \
  learn-with-me
```

### CI/CD Pipeline

The application includes a comprehensive GitHub Actions pipeline that:
- Runs tests automatically on pull requests
- Performs security and quality checks
- Builds and pushes Docker images
- Deploys to staging (develop branch) and production (main branch)

See [docs/CICD.md](docs/CICD.md) for detailed CI/CD documentation.

## 📁 Project Structure

```
learn_with_me/
├── app/
│   ├── controllers/         # Application controllers
│   │   ├── courses_controller.rb
│   │   ├── enrollments_controller.rb
│   │   ├── study_controller.rb
│   │   └── ...
│   ├── models/             # Active Record models
│   │   ├── user.rb
│   │   ├── course.rb
│   │   ├── enrollment.rb
│   │   ├── lesson.rb
│   │   └── ...
│   ├── views/              # ERB templates
│   │   ├── courses/
│   │   ├── study/
│   │   ├── dashboard/
│   │   └── ...
│   ├── javascript/         # Stimulus controllers
│   │   └── controllers/
│   └── assets/             # Stylesheets and images
├── config/                 # Application configuration
├── db/                     # Database migrations and seeds
├── test/                   # Test suite
├── .github/workflows/      # CI/CD pipelines
├── docs/                   # Documentation
└── docker-compose.yml      # Development environment
```

## 🗄 Database Schema

### Core Models

- **User**: Authentication and profile management (via Devise)
- **Student**: Extended user profile for learners
- **Role**: Role-based access control
- **Course**: Course information and metadata
- **Section**: Course organization structure
- **Lesson**: Individual learning units
- **Enrollment**: Student-course relationships
- **LessonProgress**: Lesson completion tracking
- **Author**: Course creator information
- **Review**: Course rating and feedback system

### Key Relationships

```ruby
User
├── has_one :student
├── belongs_to :role
└── has_many :enrollments (through :student)

Course
├── belongs_to :author
├── has_many :sections
├── has_many :lessons (through :sections)
├── has_many :enrollments
└── has_many :reviews

Enrollment
├── belongs_to :student
├── belongs_to :course
└── has_many :lesson_progresses
```

## 🔧 Development

### Available Commands

```bash
# Development helpers
make setup           # Initial setup
make dev_up          # Start development environment
make dev_down        # Stop development environment
make dev_test        # Run tests in Docker

# Database operations
make db_reset        # Reset database
make db_migrate      # Run migrations
make db_seed         # Seed database

# Quality assurance
make lint            # Code style check
make security_check  # Security scan
make ci_local        # Full CI pipeline

# Docker helpers
make docker_shell    # Access container shell
make docker_logs     # View container logs
make clean           # Clean up Docker resources
```

### Code Style

This project follows:
- **Ruby Style Guide** enforced by RuboCop
- **Rails Best Practices**
- **Security Guidelines** checked by Brakeman
- **Consistent Naming Conventions**

## 🤝 Contributing

1. **Fork the repository**
2. **Create a feature branch** (`git checkout -b feature/amazing-feature`)
3. **Make your changes** following our coding standards
4. **Run tests** (`make ci_local`)
5. **Commit your changes** (`git commit -m 'Add amazing feature'`)
6. **Push to the branch** (`git push origin feature/amazing-feature`)
7. **Open a Pull Request**

### Development Guidelines

- Write tests for new functionality
- Follow existing code patterns and conventions
- Update documentation when necessary
- Ensure all CI checks pass
- Use meaningful commit messages

## 🚧 Future Enhancements

### Planned Features
- **Payment Integration**: Stripe/PayPal integration for paid courses
- **Live Sessions**: Real-time video conferencing for instructor-led sessions
- **Certificates**: Automated certificate generation upon course completion
- **Mobile App**: React Native mobile application
- **Advanced Analytics**: Detailed learning analytics and reporting
- **Discussion Forums**: Course-specific discussion boards
- **Quizzes & Assessments**: Interactive quizzes and assignments
- **Multi-language Support**: Internationalization and localization

### Technical Improvements
- **Performance Optimization**: Caching strategies and database optimization
- **API Development**: RESTful API for mobile and third-party integrations
- **Advanced Search**: Elasticsearch integration for better course discovery
- **File Storage**: AWS S3 integration for video and file uploads
- **Background Jobs**: Sidekiq integration for asynchronous processing

## 📊 Monitoring & Analytics

### Application Monitoring
- **Health Checks**: Built-in health check endpoints
- **Error Tracking**: Sentry integration (configurable)
- **Performance Monitoring**: Rails built-in performance tools
- **Database Monitoring**: PostgreSQL performance insights

### User Analytics
- **Learning Progress**: Detailed progress tracking per student
- **Course Analytics**: Enrollment and completion statistics
- **User Engagement**: Session duration and interaction metrics

## 🔒 Security

### Security Measures
- **Authentication**: Secure user authentication with Devise
- **Authorization**: Role-based access control
- **CSRF Protection**: Built-in Rails CSRF protection
- **SQL Injection Prevention**: Parameterized queries
- **XSS Protection**: Content Security Policy headers
- **Vulnerability Scanning**: Automated security scans in CI/CD

### Security Best Practices
- Regular dependency updates via Dependabot
- Environment variable management for secrets
- Secure session management
- Input validation and sanitization

## 📞 Support

### Getting Help
- **Documentation**: Check this README and docs folder
- **Issues**: Report bugs or request features via GitHub Issues
- **Discussions**: Join community discussions on GitHub Discussions
- **Email**: Contact the maintainers at support@learnwithme.app

### Troubleshooting

Common issues and solutions:

1. **Database Connection Issues**
   ```bash
   # Check PostgreSQL is running
   brew services start postgresql
   # Or with Docker
   docker-compose up -d db
   ```

2. **Asset Compilation Issues**
   ```bash
   # Clear assets and recompile
   bin/rails assets:clobber assets:precompile
   ```

3. **Docker Issues**
   ```bash
   # Reset Docker environment
   make clean
   make dev_up
   ```

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## 🙏 Acknowledgments

- **Rails Community** for the excellent framework and ecosystem
- **Hotwire Team** for making modern web development enjoyable
- **Tailwind CSS** for the beautiful and functional design system
- **Open Source Contributors** who make projects like this possible

---

**Made with ❤️ by the Learn With Me Team**

[🏠 Homepage](https://learnwithme.app) | [📚 Documentation](docs/) | [🐛 Report Bug](issues/) | [💡 Request Feature](issues/)
