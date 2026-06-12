module Admin
  class DashboardController < BaseController
    def index
      @total_users = current_organization.users.count
      @total_tickets = current_organization.tickets.count
      @open_tickets = current_organization.tickets.open.count
      @resolved_tickets = current_organization.tickets.resolved.count
      @recent_tickets = current_organization.tickets.recent.limit(5)
      @recent_users = current_organization.users.reorder(created_at: :desc).limit(5)
    end
  end
end
