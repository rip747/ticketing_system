
applyTo: "**"
Ticketing System - GitHub Copilot Instructions
Project Overview
This is a multi-tenant web-based ticketing system built to manage customer support or event tickets. Each tenant (e.g., organization or client) has isolated data, with users able to create, view, update, and close tickets within their tenant's scope. Admins have additional privileges to manage tickets and users within their tenant. The system prioritizes clean code, responsive design, efficient database operations, and tenant isolation, using built-in Rails functionality to minimize external dependencies.
Technology Stack

Backend: Ruby on Rails 8.0.2.1 (Ruby 3.3.x)
Frontend: Hotwire (Turbo and Stimulus, included with Rails) for dynamic, server-rendered interactions
CSS Framework: Bootstrap 5 for styling (included via CDN or asset pipeline)
Layout Guide: AdminLTE 3 for admin dashboard layout and components
Database: SQLite with Active Record, configured for multi-tenancy
Multi-Tenancy: Custom implementation using a tenant_id column and Active Record scoping
Authentication: Custom implementation using Rails’ has_secure_password
Authorization: Custom role-based access control in controllers and models
Testing: Minitest (built-in with Rails) for unit and integration tests
Background Jobs: Active Job with async adapter (built-in) for simple asynchronous tasks
Linting/Formatting: Standard Ruby style guide, enforced manually or via rubocop (optional, included in Rails development dependencies)
CI/CD: GitHub Actions for automated testing and deployment
Deployment: Configured for local development with SQLite, deployable to Heroku or similar platforms

Coding Standards
Naming Conventions

Ruby/Rails: Follow Rails conventions: snake_case for variables, methods, and file names; CamelCase for classes and modules.
Database: Use snake_case for table and column names.
Stimulus Controllers: Use kebab-case for controller names (e.g., ticket-form-controller.js).
Constants: Use SCREAMING_SNAKE_CASE.
Tenant Identifiers: Use tenant_id for tenant-specific fields.

Code Style

Follow Ruby Style Guide and Rails conventions (e.g., RESTful routes, skinny controllers).
Keep methods short (under 10 lines where possible) and focused.
Use meaningful names that reflect purpose (e.g., ticket_status instead of status).
Use Bootstrap 5 classes for styling, aligned with AdminLTE’s layout (e.g., card, content-wrapper).
Ensure all tenant-specific data access includes tenant_id scoping.
Avoid external gems unless absolutely necessary; use built-in Rails features (e.g., Active Record, Active Job).

Error Handling

Use Rails’ rescue_from in controllers for centralized error handling.
Return user-friendly error messages in JSON or HTML responses:# Example JSON response
render json: {
  success: false,
  error: "Invalid ticket data",
  details: ticket.errors.full_messages,
  meta: { timestamp: Time.current.iso8601 }
}, status: :unprocessable_entity


Log errors using Rails’ logger with tenant and user context (e.g., tenant_id, user_id).

Testing

Write Minitest tests for models, controllers, and helpers (aim for 85%+ coverage).
Use Rails’ built-in fixtures or custom test data setup (avoid FactoryBot).
Write system tests for critical user flows (e.g., ticket creation, tenant switching).
Include multi-tenancy tests to verify data isolation using tenant_id.
Run rails test before committing.

Architecture Patterns

Backend: Follow Rails MVC pattern.
Use service objects for complex business logic (e.g., app/services/ticket_service.rb).
Implement Active Record scopes for reusable queries (e.g., scope :active, -> { where(status: 'open') }).


Multi-Tenancy:
Implement multi-tenancy using a tenant_id column on relevant models (e.g., Ticket, User).
Scope queries with default_scope { where(tenant_id: Current.tenant_id) } in tenant-aware models.
Use a Current object (e.g., Current.tenant_id) to store the current tenant context, set via middleware or controller before_action.
Identify tenants via subdomains (e.g., tenant1.example.com) or URL parameters (e.g., /tenants/:tenant_id).


Frontend: Use Hotwire (Turbo for server-rendered updates, Stimulus for JavaScript interactivity).
Prefer Turbo Streams for real-time updates (e.g., ticket status changes).
Use AdminLTE’s layout structure (e.g., main-sidebar, content-wrapper) with Bootstrap 5 classes.


Database: Use SQLite with Active Record, optimized for multi-tenancy.
Add tenant_id to all tenant-scoped models (e.g., tickets, users).
Implement indexes for frequently queried fields (e.g., tenant_id, ticket_id, user_id).
Use soft deletes (e.g., deleted_at column) instead of hard deletes.



Development Workflow
Before Committing

Run rails test to ensure all tests pass.
Manually verify code style aligns with Ruby Style Guide (or use rubocop -a if included).
Use conventional commit messages (e.g., feat: add ticket creation endpoint, fix: resolve tenant switching bug).
Verify tenant isolation in development (e.g., switch tenants to test data separation).

Project Structure

app/: Rails application code
controllers/: RESTful controllers (e.g., tickets_controller.rb)
models/: Active Record models with tenant scoping (e.g., ticket.rb)
services/: Business logic (e.g., ticket_service.rb)
views/: ERB templates with Hotwire and AdminLTE layouts
helpers/: View helpers for common UI components
assets/javascripts/: Stimulus controllers (e.g., ticket-form-controller.js)
assets/stylesheets/: Bootstrap 5 and AdminLTE custom styles


test/: Minitest tests
models/, controllers/, helpers/, system/: Test suites


config/: Rails configuration
initializers/current.rb: Sets up Current object for tenant context


.github/workflows/: CI/CD workflows for GitHub Actions
Gemfile: Minimal gems (e.g., rails, sqlite3, bootsnap)

Common Patterns
Controller Example
# app/controllers/tickets_controller.rb
class TicketsController < ApplicationController
  before_action :authenticate_user
  before_action :set_current_tenant

  def create
    @ticket = Ticket.new(ticket_params)
    @ticket.user_id = current_user.id
    @ticket.tenant_id = Current.tenant_id

    if @ticket.save
      Rails.logger.info("Ticket created for tenant #{Current.tenant_id}, user #{current_user.id}")
      respond_to do |format|
        format.turbo_stream { render turbo_stream: turbo_stream.append("tickets", partial: "tickets/ticket", locals: { ticket: @ticket }) }
        format.json { render json: { success: true, data: @ticket, message: "Ticket created" }, status: :created }
      end
    else
      Rails.logger.error("Ticket creation failed: #{@ticket.errors.full_messages}")
      respond_to do |format|
        format.turbo_stream { render turbo_stream: turbo_stream.replace("ticket_form", partial: "tickets/form", locals: { ticket: @ticket }) }
        format.json { render json: { success: false, error: @ticket.errors.full_messages }, status: :unprocessable_entity }
      end
    end
  end

  private

  def set_current_tenant
    Current.tenant_id = Tenant.find_by(subdomain: request.subdomain)&.id
    redirect_to root_path, alert: "Invalid tenant" unless Current.tenant_id
  end

  def ticket_params
    params.require(:ticket).permit(:title, :description, :priority, :status)
  end
end

Model Example
# app/models/ticket.rb
class Ticket < ApplicationRecord
  default_scope { where(tenant_id: Current.tenant_id) }
  belongs_to :user
  belongs_to :tenant

  validates :title, presence: true
  validates :priority, inclusion: { in: %w[low medium high] }
  validates :status, inclusion: { in: %w[open in_progress closed] }

  scope :active, -> { where(status: "open") }
end

Current Object Example
# config/initializers/current.rb
class Current < ActiveSupport::CurrentAttributes
  attribute :tenant_id
end

Stimulus Controller Example
// app/javascript/controllers/ticket_form_controller.js
import { Controller } from "@hotwired/stimulus";

export default class extends Controller {
  static targets = ["form", "error"];

  submit(event) {
    event.preventDefault();
    fetch(this.formTarget.action, {
      method: "POST",
      body: new FormData(this.formTarget),
      headers: { "Accept": "text/vnd.turbo-stream.html" }
    })
      .then(response => response.text())
      .then(html => Turbo.renderStreamMessage(html))
      .catch(error => {
        this.errorTarget.textContent = "Failed to submit ticket";
        console.error(error);
      });
  }
}

View Example
<!-- app/views/layouts/application.html.erb -->
<!DOCTYPE html>
<html>
<head>
  <title>Ticketing System</title>
  <%= csrf_meta_tags %>
  <%= csp_meta_tag %>
  <%= stylesheet_link_tag "application", "data-turbo-track": "reload" %>
  <%= javascript_importmap_tags %>
  <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/css/bootstrap.min.css" rel="stylesheet">
  <link href="https://cdn.jsdelivr.net/npm/admin-lte@3.2/dist/css/adminlte.min.css" rel="stylesheet">
</head>
<body class="hold-transition sidebar-mini">
  <div class="wrapper">
    <aside class="main-sidebar sidebar-dark-primary">
      <!-- AdminLTE Sidebar -->
      <div class="sidebar">
        <nav class="mt-2">
          <ul class="nav nav-pills nav-sidebar flex-column">
            <li class="nav-item">
              <%= link_to "Tickets", tickets_path, class: "nav-link" %>
            </li>
          </ul>
        </nav>
      </div>
    </aside>
    <div class="content-wrapper">
      <section class="content">
        <%= yield %>
      </section>
    </div>
  </div>
  <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/js/bootstrap.bundle.min.js"></script>
  <script src="https://cdn.jsdelivr.net/npm/admin-lte@3.2/dist/js/adminlte.min.js"></script>
</body>
</html>

Key Guidelines

Always scope database queries with tenant_id using default_scope or explicit conditions.
Use has_secure_password for authentication, with custom session management in controllers.
Implement role-based authorization (e.g., admin, user) via model methods or controller checks.
Use Turbo Streams for dynamic updates (e.g., ticket creation, status changes).
Log all critical operations with tenant and user context.
Optimize SQLite queries with indexes on tenant_id, user_id, and ticket_id.
Follow AdminLTE’s layout conventions (e.g., main-sidebar, content-wrapper) with Bootstrap 5 classes.
Avoid external gems; use built-in Rails features like Active Record, Active Job, and Action Mailer.

Copilot-Specific Instructions

Prioritize Ruby on Rails built-in functionality over external gems.
Use the provided examples as templates for new code.
If unsure about context, analyze #codebase to infer patterns.
For controllers, follow the TicketsController example with Turbo Stream and JSON responses.
For models, include tenant_id scoping and validations as shown in Ticket.
For frontend, use Hotwire (Turbo/Stimulus) with AdminLTE and Bootstrap 5 styling.
Avoid generating code that adds external gem dependencies.
If feedback includes "do this instead" or "don't do that," update these instructions accordingly.

Contribution Guidelines

Create feature branches for new development (e.g., feat/ticket-status-update).
Submit pull requests with clear descriptions and link to relevant issues.
Ensure all CI/CD checks pass before merging.
Update documentation in README.md or docs/ for new features.
