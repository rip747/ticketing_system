# HelpDesk Ticketing System

A multi-tenant HelpDesk ticketing application built with Ruby on Rails 8, featuring Hotwire (Turbo + Stimulus) for dynamic interactions, Bootstrap 5 for the UI, and a Mantis-inspired dashboard design.

## Features

- **Role-based access** — Admins, agents, and customers with appropriate permissions
- **Ticket management** — Create, assign, update, close, and reopen tickets
- **Rich text descriptions** — Powered by ActionText with image and attachment support
- **Real-time updates** — Turbo Streams and ActionCable for live UI updates
- **Department & category hierarchy** — Tickets organized by department and category
- **Full-text search** — Search tickets by subject and description
- **Filtering** — Filter tickets by status, priority, and department
- **Commenting** — Threaded comments on tickets with Turbo Streams
- **Admin panel** — Manage departments, categories, and users
- **Dashboard** — At-a-glance stats with status/priority/department breakdowns
- **Multi-tenant** — Users only see their own tickets (customers) or assigned tickets (agents)

## Tech Stack

| Layer | Technology |
|---|---|
| **Framework** | Ruby on Rails 8.1.3 |
| **Database** | SQLite (development/test) |
| **Frontend** | Hotwire (Turbo + Stimulus), Bootstrap 5.3 |
| **Auth** | `has_secure_password` (bcrypt) |
| **Rich Text** | ActionText |
| **Assets** | Propshaft, Importmap |
| **Testing** | Minitest, Capybara |
| **Coverage** | SimpleCov |

## Getting Started

### Prerequisites

- Ruby 4.0+
- Bundler
- SQLite

### Setup

```bash
# Clone the repository
git clone <repo-url>
cd ticketing_system

# Install dependencies
bundle install

# Create, migrate, and seed the database
bin/rails db:setup

# Start the server
bin/dev
```

Visit [http://localhost:3000](http://localhost:3000)

### Seed Accounts

| Role | Email | Password |
|---|---|---|
| Admin | admin@helpdesk.com | password123 |
| Agent | sarah@helpdesk.com | password123 |
| Agent | mike@helpdesk.com | password123 |
| Agent | emma@helpdesk.com | password123 |
| Customer | john@example.com | password123 |

## Testing

The project uses **Minitest** with fixture-based test data (no FactoryBot).

### Run all tests

```bash
bin/rails test
bin/rails test:system       # system tests (Capybara)
```

### Run with coverage

```bash
bin/test_with_coverage       # full suite, single-worker for accurate coverage
bin/test_with_coverage test/models/  # specific test directory
```

Coverage reports are generated to `coverage/index.html`.

### Test structure

| Directory | Tests |
|---|---|
| `test/models/` | 73 unit tests — validations, scopes, associations, state methods |
| `test/controllers/` | 93 controller tests — CRUD, auth gates, role-based access |
| `test/integration/` | 9 integration tests — full user flows |
| `test/system/` | 4 system tests — end-to-end via Capybara |
| `test/helpers/` | 1 helper test |

**Total: 180 tests, 461 assertions, 100% line coverage**

## Architecture

### MVC Structure

```
app/
├── controllers/
│   ├── admin/              # Admin namespace controllers
│   │   ├── base_controller.rb
│   │   ├── categories_controller.rb
│   │   ├── dashboard_controller.rb
│   │   ├── departments_controller.rb
│   │   └── users_controller.rb
│   ├── application_controller.rb
│   ├── comments_controller.rb
│   ├── dashboard_controller.rb
│   ├── departments_controller.rb
│   ├── sessions_controller.rb
│   ├── tickets_controller.rb
│   └── users_controller.rb
├── models/
│   ├── application_record.rb
│   ├── category.rb
│   ├── comment.rb
│   ├── department.rb
│   ├── ticket.rb
│   └── user.rb
└── views/
    ├── admin/
    ├── layouts/
    ├── sessions/
    ├── tickets/
    └── users/
```

### Models

| Model | Key Associations |
|---|---|
| **User** | `belongs_to :department`, `has_many :tickets`, `has_many :assigned_tickets` |
| **Department** | `has_many :users`, `has_many :categories`, `has_many :tickets` |
| **Category** | `belongs_to :department`, `has_many :tickets` |
| **Ticket** | `belongs_to :user`, `belongs_to :assigned_user`, `belongs_to :category`, `belongs_to :department`, `has_many :comments`, `has_rich_text :description` |
| **Comment** | `belongs_to :user`, `belongs_to :ticket` |

### Key Routes

```
/login                  SessionsController#new
/tickets                TicketsController (CRUD)
/tickets/:id/assign     TicketsController#assign
/tickets/:id/close      TicketsController#close
/tickets/:id/reopen     TicketsController#reopen
/profile                UsersController#show
/admin                  Admin::DashboardController#index
/admin/departments      Admin::DepartmentsController (CRUD)
/admin/categories       Admin::CategoriesController (CRUD)
/admin/users            Admin::UsersController (CRUD)
```

## Code Standards

This project follows the conventions outlined in `Agents.md`:

- **Rails conventions first** — MVC, RESTful routing, skinny controllers, fat models
- **No unnecessary gems** — Use native Rails components before adding dependencies
- **Hotwire over SPA** — All dynamic behavior via Turbo and Stimulus, no raw JS or AJAX
- **Bootstrap 5** — Utility classes first, Sass variable overrides for theming
- **Minitest only** — Fixtures over factories, no RSpec
- **Database-level integrity** — Foreign keys, not-null constraints, and indexes alongside model validations
- **Multi-tenant security** — Users never see data outside their organization scope

## Deployment

### Docker

A `Dockerfile` and `config/deploy.yml` (Kamal) are included for containerized deployment.

```bash
bin/rails db:prepare        # Create and migrate the DB
bin/rails assets:precompile # Build assets
bin/rails server            # Start Puma
```

### Environment Variables

| Variable | Description |
|---|---|
| `RAILS_ENV` | Environment (development/test/production) |
| `DATABASE_URL` | Database connection string |
| `SECRET_KEY_BASE` | Rails secret key base |

---

Built with [Ruby on Rails 8](https://rubyonrails.org/)
