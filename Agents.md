# Developer Agent Standards & Instructions (`agent.md`)

This document serves as the absolute operational system prompt and code standards guide for any AI developer agents or engineers working on this Ruby on Rails application. It details architectural constraints, frontend approaches, and testing paradigms that must be strictly followed.

---

## 1. Core Philosophy: Rails Conventions First

* **Convention over Configuration (CoC):** Adhere strictly to default Rails design patterns (MVC, RESTful routing, skinny controllers, fat models).
* **Minimalist Gem Dependency:** Do not add external gems if the required feature can be elegantly built using native Rails components. 
    * *Examples:* Use built-in Active Storage for files (not third-party wrappers), Active Job for queueing, Rails encrypted credentials for keys, and generic Action Mailer configurations.
* **Database-Level Integrity:** Enforce data safety at the lowest layer. Always include appropriate database constraints (`null: false`, foreign keys, explicit indexes for queried columns, unique constraints) alongside Active Record model validations.
* **N+1 Query Elimination:** Always look out for and fix N+1 query patterns by utilizing `.includes`, `.preload`, or `.eager_load`.
* **Multi-Tenant Data Isolation:** This is a **multi-tenant application**. Every query, model scope, controller action, and background job must be scoped to the current organization. Never allow users to access data belonging to a different organization. Always derive `organization_id` from `Current.organization`, never from user-supplied parameters.

---

## 2. Frontend Architecture: Hotwire & Stimulus

All dynamic user experiences, asynchronous workflows, and real-time DOM updates must be written using **Hotwire (Turbo & Stimulus)**. Single Page Application (SPA) paradigms or custom global JavaScript script tags are strictly prohibited.

### Turbo (Drive, Frames, Streams)
* **Turbo Drive:** Maintain the app to be fully compatible with Turbo Drive navigation. Avoid `window` or `document` level state mutations that break or leak memory across page transitions.
* **Turbo Frames:** Use `<turbo-frame>` elements to isolate heavy or interactive regions of a page (e.g., inline forms, tab interfaces, lazy-loaded components, pagination) to prevent full-page refreshes.
* **Turbo Streams:** Use Turbo Streams to append, prepend, remove, or replace specific DOM pieces in response to standard controller form actions or real-time broadcasts via ActionCable.

### Stimulus JS
* **HTML-Centric Behavior:** Use Stimulus controllers purely to add behavior, handle event listeners, and manipulate CSS classes or attributes. Stimulus should **not** be used to render large chunks of HTML; rely on server-rendered Rails views/partials.
* **State Tracking:** Maintain state inside the HTML using Stimulus `values` and `classes` attributes, allowing the DOM to act as the single source of truth.
* **Lifecycle Discipline:** Always clean up event listeners, timers, or third-party instances inside the `disconnect()` lifecycle hook to avoid memory leaks during Turbo navigations.

---

## 3. CSS Framework: Bootstrap

The user interface must be styled strictly using **Bootstrap**.

* **Utility Classes First:** Prioritize Bootstrap’s utility classes directly in view partials for managing margins (`m-*`), padding (`p-*`), flex layouts (`d-flex`), text alignments, and background states before writing custom CSS rules.
* **Sass Theme Configuration:** When visual modifications are required, customize Bootstrap’s global theme by overriding its Sass variables (e.g., inside `app/assets/stylesheets/application.bootstrap.scss`) rather than writing heavy overriding CSS classes.
* **Hotwire Integration:** When initializing interactive Bootstrap JS modules (such as Modals, Dropdowns, or Tooltips), ensure they are wrapped inside a Stimulus controller’s `connect()` and `disconnect()` actions so they initialize and teardown gracefully during Turbo updates.

---

## 4. Testing Paradigm: Minitest

The application relies entirely on **Minitest** (the native Rails testing suite). The introduction of RSpec, FactoryBot, or other heavy testing suites is forbidden.

### Test Architecture & Fixtures
* **Fixtures Over Factories:** Use standard Rails YAML fixtures (`test/fixtures/*.yml`) to maintain state and relationship baselines. Keep fixtures lean, readable, and strictly meaningful. Ensure every fixture file includes records belonging to at least two different organizations to properly test multi-tenant isolation.
* **Model Testing (Unit):** Test edge cases for validations, custom scopes, complex associations, and model-level business logic calculations. **Every model test must include assertions that data from one organization is inaccessible when scoped to another organization.** Use fixtures from multiple organizations to verify scope isolation.
* **Controller / Integration Testing (Functional):** Verify correct HTTP status codes, flash messages, redirect flows, and secure session management. **Every controller test must include cross-tenant access attempts** — e.g., authenticate as a user from Organization A and assert that records belonging to Organization B are not accessible (return 404, redirect, or raise `ActiveRecord::RecordNotFound`).
* **Sys Admin Edge Case:** Every controller that uses `current_organization` must also be tested with a sys admin user (who has no organization). Sys admins accessing org-scoped controllers must either be redirected (e.g., to `system_root_path`) or receive a `404`/`403` response. This catches the common bug where `current_organization` returns `nil` and a method like `.departments` is called on nil.
* **System Testing (End-to-End):** Use Rails System Tests (`ApplicationSystemTestCase`) powered by Capybara to test user interaction pipelines. Ensure system tests specifically assert the visual and structural DOM adjustments caused by Turbo Streams and Stimulus interactions. **System tests must include scenarios where a user cannot see, access, or interact with data from another organization.**

### Multi-Tenant Testing Requirements
* **Organization-Aware Fixtures:** Every fixture file must include records for at least two organizations (e.g., `organization_one` and `organization_two`). Tests must use `Current.organization=` to establish the tenant context before exercising code.
* **Set Tenant Context in Tests:** Controller and integration tests must set `Current.organization` to the appropriate organization before making requests. Use `setup` blocks to establish tenant context based on the authenticated user.
* **Cross-Tenant Attack Vectors:** Test that no endpoint accepts `organization_id` as a parameter from the request. Test that URL tampering (e.g., changing an ID in the path to a record owned by another org) is properly rejected.
* **Scope Assertions:** For every tenant-scoped model, write a test that creates records in two different organizations and asserts that scoped queries only return records for the current organization. Use `assert_includes` and `assert_not_includes` to verify inclusion/exclusion at the record level.
* **Job & Mailer Isolation:** Background jobs and mailers must also be tested for multi-tenant correctness. Jobs that operate on records must verify the record belongs to the expected organization before performing work. Mailer tests should confirm that email content does not leak cross-organization data.

---

## 5. Agent Verification Checklist

Before proposing or committing any code changes, evaluate your execution against this protocol:

1.  **Dependency Check:** Did I look for a native Rails solution or existing package feature before proposing a new gem addition to the `Gemfile`?
2.  **Database Migration Safety:** Did I include foreign key constraints, index declarations, and `null: false` constraints where data integrity requires it?
3.  **Hotwire Compliance:** Did I implement the dynamic interaction using a Turbo Frame, Turbo Stream response, or standard Stimulus controller instead of raw legacy JS or manual AJAX?
4.  **Bootstrap Styling:** Does the markup rely on native Bootstrap components and layout grids, ensuring visual consistency?
5.  **Minitest Enforcement:** Did I write accompanying Unit, Integration, or System tests using standard Minitest configurations? Do all project tests pass cleanly without errors?
6.  **Brakeman Security Scan:** Did you run `bin/brakeman --no-pager --ignore-config config/brakeman.ignore` and confirm there are **zero new security warnings**? If any new warnings appeared, they must be resolved before committing. Only pre-existing, intentional warnings (e.g., admin controller mass assignment) should be in the ignore config.
7.  **RuboCop Linting:** Did you run `bin/rubocop` and confirm there are **zero offenses**? Run `bin/rubocop -a` to auto-correct any fixable issues before manual review.
8.  **Multi-Tenant Data Isolation:** Are all queries, controller actions, and background jobs properly scoped to `Current.organization`? Did I verify that no `organization_id` parameter from the request can bypass the tenant context? Are foreign key constraints and indexes in place for `organization_id` on every tenant-scoped table?
9.  **Sys Admin Nil-Organization Guard:** Does every controller that references `current_organization` handle the case where the user is a `sys_admin` (who has `nil` organization)? Have I added a `before_action` or redirect guard for sys admin users? Have I written a failing test for this case first?

## Style

1. The style of the project should following the layout of Mantis (https://mantisdashboard.com/codeignitor/default/public/dashboard-default)
2. Any dashboards should use the foloowing dashboard as a refernce (https://mantisdashboard.com/codeignitor/default/public/helpdesk-dashboard)

## Code Layout

1. Almost all of the code for the project will live in the /app directory

## Do

1. When validating user input, make sure that the validations happen at the model and controller layer first, then add validations at the UI level. You should always assume that someone will try to hack or by pass the UI through the dev tools in a browser.
2. Always assume a security first approach. Users should never be able to see each others information unless they are part of the same organization.
3. This application is a **multi-tenant application**. All code — models, controllers, views, jobs, mailers, and tests — must enforce organization-level data isolation. The `organization_id` must never be accepted from user-supplied parameters; it must always be inferred from `Current.organization`.
4. Test driven development. Test should been written first for the functionality and features. Those tests should fail and code should be written to make those tests pass.
    a.Always make sure that tests pass at the lower levels (models/controllers/jobs/mailers/helpers/views/) before performing system tests (user interface)
    b. Units Tests should be written for ALL funcitonality.
    c. Use the gem simplecov in order to make sure that all funtionality is tested.
    d. **Every controller** must be tested with **all applicable user roles** — including `sys_admin`. If a controller accesses `current_organization`, it must handle the nil case (sys admin has no org). Write the failing test for the sys admin role before adding the guard clause.
5. All CSS should be in a separate file as much as possible. I understand that some CSS might have to be inline, however I don't want CSS in the header of the application.
6. Any textareas MUST be rich text and allow for images and attachments using ActionText
7. Use hHotWire when submitting forms so that the page doesn't refresh.
8. Use ActionCable as much as possible so that if 2 people are using the applicaiton at the same time, updates will happen in real time.
9. Use Partials as much as possible so you don't repeat yourself. You can especially do that with create and edit forms.
10. Mobile first. Make sure that functionality will work on a mobile device. 
11. Try to always use stimulus when you can and DO NOT use inline javascript unless absolutely nescessary.


## Multi-Tenant Architecture Summary

This application uses a **shared-database, shared-schema** multi-tenant model where tenant identity is derived from the currently authenticated user's `organization_id`. Key architectural points:

* **Tenant Identification:** The current organization is determined by `Current.organization` (set via `Current` model from the authenticated user's organization). Every controller `before_action` should establish this context.
* **Data Scoping:** All tenant-scoped models `belongs_to :organization`. Queries should be chained off the current organization (e.g., `Current.organization.tickets.active`) rather than using top-level model classes directly.
* **Authentication:** User login establishes session identity; the organization is derived from the user record, never from user-supplied parameters.
* **Cross-Tenant Prevention:** Never allow an `organization_id` parameter from the request to override the inferred organization from `Current.organization`. Always ignore or strip organization_id from permitted parameters in controllers.

---

## Goals
1. To be feature and API compatable with the following ticketing systems so users on those system can migrate away from them:
    a. ConnectWise PSA
        1. Platform Information: https://www.connectwise.com/platform/psa
        2. Features: https://www.connectwise.com/platform/psa#features
    b. Solarwinds WebHelpDesk
        1. Production Information: https://www.solarwinds.com/web-help-desk
        2. Features: https://www.solarwinds.com/web-help-desk/use-cases?page=1