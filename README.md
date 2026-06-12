# HelpDesk Ticketing System

A **multi-tenant** HelpDesk ticketing application built with Ruby on Rails 8, featuring Hotwire (Turbo + Stimulus) for dynamic interactions, Bootstrap 5 for the UI, and a Mantis-inspired dashboard design.

## Features

- **Multi-tenant architecture** — Organizations are fully isolated; users never see data from other orgs
- **Role-based access** — System Admins, Org Admins, agents, and customers with appropriate permissions
- **Two admin areas** — Separate Organization Admin and System Admin panels with distinct login URLs
- **Ticket management** — Create, assign, update, close, and reopen tickets
- **Rich text descriptions** — Powered by ActionText with image and attachment support
- **Real-time updates** — Turbo Streams and ActionCable for live UI updates
- **Department & category hierarchy** — Tickets organized by department and category (per-org)
- **Full-text search** — Search tickets by subject and description
- **Filtering** — Filter tickets by status, priority, and department
- **Commenting** — Threaded comments on tickets with Turbo Streams
- **Organization Admin panel** — Manage departments, categories, and users within your org
- **System Admin panel** — Manage all organizations, users, and system settings
- **Dashboard** — At-a-glance stats with status/priority/department breakdowns

## Multi-Tenant Architecture

This application uses a **shared-database, shared-schema** multi-tenant model.

### Tenant Isolation

| Layer | Mechanism |
|---|---|
| **Models** | Every tenant-scoped model has `organization_id` with FK constraint |
| **Controllers** | All queries chain off `current_organization` — never from user-supplied params |
| **Sessions** | `current_organization` is derived from `current_user.organization`, never from request params |
| **Current** | Thread-safe `Current.organization` via `ActiveSupport::CurrentAttributes` |

### Design Principles

- **Organization ID is never accepted from parameters** — always inferred from `Current.organization`
- **System Administrators** have no org affiliation — `organization_id` is `NULL` for `sys_admin` users
- **Emails are globally unique** — to support sys_admin accounts existing outside any org

## Role System

| Role | Scope | Capabilities |
|---|---|---|
| **`sys_admin`** | Global | Manages all organizations, views all data across the system |
| **`org_admin`** | Per-organization | Manages their org's departments, categories, users, and tickets |
| **`agent`** | Per-organization | Views and edits tickets assigned to them, manages tickets in their org |
| **`customer`** | Per-organization | Creates and views only their own tickets |

### Role Delegation

Org Admins can create users and assign them as agents or other org admins through the Organization Admin panel, allowing flexible delegation within each organization.

## Two Admin Areas

### 1. Organization Admin (`/admin/*`)

For org-level administrators managing their own organization.

| Route | Purpose |
|---|---|
| `/admin` | Org admin dashboard — user/ticket counts, recent activity |
| `/admin/departments` | Manage departments within the org |
| `/admin/categories` | Manage ticket categories within the org |
| `/admin/users` | Manage users within the org (create agents, org admins, customers) |

### 2. System Admin (`/system/*`)

For system administrators managing the entire platform across all organizations.

| Route | Purpose |
|---|---|
| `/system/login` | **Separate login** for system administrators (distinct from `/login`) |
| `/system` | System dashboard — cross-org stats, ticket status breakdown |
| `/system/organizations` | CRUD management of all organizations |

The System Admin login is at a **separate URL** (`/system/login`) so it can be locked down by IP address or other means if necessary. A **fixed red banner** appears at the bottom of every page when logged in as a System Administrator.

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

Visit [http://localhost:3000](http://localhost:3000) for the main application.
Visit [http://localhost:3000/system/login](http://localhost:3000/system/login) for the System Admin panel.

### Seed Accounts

| Role | Email | Password | Login URL |
|---|---|---|---|
| System Admin | sysadmin@helpdesk.com | password123 | `/system/login` |
| Org Admin | admin@helpdesk.com | password123 | `/login` |
| Agent | sarah@helpdesk.com | password123 | `/login` |
| Agent | mike@helpdesk.com | password123 | `/login` |
| Agent | emma@helpdesk.com | password123 | `/login` |
| Customer | john@example.com | password123 | `/login` |

## Registration

New users sign up at `/register` by providing:
1. **Organization Name** — Creates a new tenant organization
2. **Their name, email, and password**

The first user of an organization is automatically assigned the **Org Admin** role and can then invite additional users.

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

| Directory | Tests | Description |
|---|---|---|
| `test/models/` | 85 unit tests | Validations, scopes, associations, role methods, multi-tenant isolation |
| `test/controllers/` | 98 controller tests | CRUD, auth gates, role-based access, tenant scoping |
| `test/integration/` | 7 integration tests | Full user flows including registration with org creation |
| `test/system/` | 4 system tests | End-to-end via Capybara |

**Total: 192 tests, 489 assertions**

### Multi-Tenant Testing

- All fixtures include `organization: default` to ensure proper tenant scoping
- `test_helper.rb` sets `Current.organization` in model test `setup` and integration `login_as` helpers
- Sys admin fixture (`users(:sys_admin)`) has no organization affiliation
- Cross-tenant access attempts are tested to ensure proper isolation

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
