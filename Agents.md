# Developer Agent Standards & Instructions (`agent.md`)

This document serves as the absolute operational system prompt and code standards guide for any AI developer agents or engineers working on this Ruby on Rails application. It details architectural constraints, frontend approaches, and testing paradigms that must be strictly followed.

---

## 1. Core Philosophy: Rails Conventions First

* **Convention over Configuration (CoC):** Adhere strictly to default Rails design patterns (MVC, RESTful routing, skinny controllers, fat models).
* **Minimalist Gem Dependency:** Do not add external gems if the required feature can be elegantly built using native Rails components. 
    * *Examples:* Use built-in Active Storage for files (not third-party wrappers), Active Job for queueing, Rails encrypted credentials for keys, and generic Action Mailer configurations.
* **Database-Level Integrity:** Enforce data safety at the lowest layer. Always include appropriate database constraints (`null: false`, foreign keys, explicit indexes for queried columns, unique constraints) alongside Active Record model validations.
* **N+1 Query Elimination:** Always look out for and fix N+1 query patterns by utilizing `.includes`, `.preload`, or `.eager_load`.

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
* **Fixtures Over Factories:** Use standard Rails YAML fixtures (`test/fixtures/*.yml`) to maintain state and relationship baselines. Keep fixtures lean, readable, and strictly meaningful.
* **Model Testing (Unit):** Test edge cases for validations, custom scopes, complex associations, and model-level business logic calculations.
* **Controller / Integration Testing (Functional):** Verify correct HTTP status codes, flash messages, redirect flows, and secure session management.
* **System Testing (End-to-End):** Use Rails System Tests (`ApplicationSystemTestCase`) powered by Capybara to test user interaction pipelines. Ensure system tests specifically assert the visual and structural DOM adjustments caused by Turbo Streams and Stimulus interactions.

---

## 5. Agent Verification Checklist

Before proposing or committing any code changes, evaluate your execution against this protocol:

1.  **Dependency Check:** Did I look for a native Rails solution or existing package feature before proposing a new gem addition to the `Gemfile`?
2.  **Database Migration Safety:** Did I include foreign key constraints, index declarations, and `null: false` constraints where data integrity requires it?
3.  **Hotwire Compliance:** Did I implement the dynamic interaction using a Turbo Frame, Turbo Stream response, or standard Stimulus controller instead of raw legacy JS or manual AJAX?
4.  **Bootstrap Styling:** Does the markup rely on native Bootstrap components and layout grids, ensuring visual consistency?
5.  **Minitest Enforcement:** Did I write accompanying Unit, Integration, or System tests using standard Minitest configurations? Do all project tests pass cleanly without errors?

## Style

1. The style of the project should following the layout of Mantis (https://mantisdashboard.com/codeignitor/default/public/dashboard-default)
2. Any dashboards should use the foloowing dashboard as a refernce (https://mantisdashboard.com/codeignitor/default/public/helpdesk-dashboard)