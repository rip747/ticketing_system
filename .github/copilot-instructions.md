# GitHub Copilot Instructions for AI Agents

## Project Overview
- Multi-tenant ticketing system for customer support/events
- Built with Ruby on Rails 8, Hotwire (Turbo/Stimulus), Bootstrap 5, AdminLTE 3
- Data isolation via `tenant_id` on models; tenant context managed by `Current.tenant_id`
- SQLite for local dev; deployable to Heroku

## Architecture & Patterns
- **MVC Structure:**
  - Controllers: RESTful, tenant-aware, Turbo Stream + JSON responses (see `app/controllers/tickets_controller.rb`)
  - Models: `tenant_id` scoping via `default_scope`, strict validations (see `app/models/ticket.rb`)
  - Views: ERB, Hotwire, AdminLTE layout (`app/views/layouts/application.html.erb`)
- **Multi-Tenancy:**
  - All queries scoped by `tenant_id` (use `Current.tenant_id`)
  - Tenants identified by subdomain or URL param
- **Authentication/Authorization:**
  - Custom, using `has_secure_password` and role checks
  - Session logic in controllers
- **Frontend:**
  - Hotwire for dynamic UI, Bootstrap 5 for styling
  - Stimulus controllers in `app/javascript/controllers/`
- **Background Jobs:**
  - Use Rails Active Job (async adapter)
- **Testing:**
  - Minitest only; fixtures for test data
  - System tests for flows, multi-tenancy isolation

## Developer Workflow
- **Start Dev Server:** `bin/dev`
- **Run Tests:** `rails test`
- **Lint (optional):** `bin/rubocop`
- **Migrations:** `rails db:migrate`
- **Seed DB:** `rails db:seed`

## Key Conventions
- **Naming:**
  - snake_case for files, DB columns
  - CamelCase for classes
  - Stimulus: kebab-case (e.g., `ticket-form-controller.js`)
- **Error Handling:**
  - Use `rescue_from` in controllers
  - Log errors with tenant/user context
  - User-friendly JSON/HTML error responses
- **No External Gems:**
  - Use built-in Rails features only

## Examples
- **Controller:**
  - See `TicketsController#create` for Turbo Stream/JSON pattern
- **Model:**
  - See `Ticket` for tenant scoping and validations
- **Stimulus:**
  - See `app/javascript/controllers/ticket_form_controller.js`
- **Layout:**
  - See `app/views/layouts/application.html.erb` for AdminLTE/Bootstrap integration

## Directory Structure
- `app/` (controllers, models, views, assets)
- `config/` (routes, initializers, environments)
- `test/` (Minitest suites)
- `.github/` (CI/CD workflows)

## Integration Points
- Hotwire (Turbo/Stimulus) for frontend
- AdminLTE via CDN for dashboard UI
- SQLite for DB (local dev)

---
**For unclear patterns or missing info, ask for clarification or review referenced example files.**
