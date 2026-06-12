module System
  class DashboardController < BaseController
    def index
      @total_organizations = Organization.count
      @total_users = User.count
      @total_tickets = Ticket.count
      @total_sys_admins = User.sys_admins.count
      @recent_organizations = Organization.reorder(created_at: :desc).limit(5)
      @tickets_by_status = Ticket.group(:status).count
    end
  end
end
