module Admin
  class DashboardController < BaseController
    def index
      @total_users = User.count
      @total_tickets = Ticket.count
      @open_tickets = Ticket.open.count
      @resolved_tickets = Ticket.resolved.count
      @recent_tickets = Ticket.recent.limit(5)
      @recent_users = User.reorder(created_at: :desc).limit(5)
    end
  end
end
