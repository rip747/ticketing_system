class DashboardController < ApplicationController
  before_action :require_login

  def index
    @tickets_scope = tickets_for_current_user

    @total_tickets = @tickets_scope.count
    @open_tickets = @tickets_scope.open.count
    @pending_tickets = @tickets_scope.pending.count
    @resolved_tickets = @tickets_scope.resolved.count
    @closed_tickets = @tickets_scope.closed.count
    @unassigned_tickets = @tickets_scope.unassigned.count

    @tickets_by_priority = @tickets_scope.group(:priority).count
    @tickets_by_status = @tickets_scope.group(:status).count
    @tickets_by_department = Department.where(id: @tickets_scope.select(:department_id))
                                        .joins(:tickets)
                                        .merge(@tickets_scope)
                                        .group(:name)
                                        .count

    @recent_tickets = @tickets_scope.recent.limit(5)
  end

  private

  def tickets_for_current_user
    if current_user.admin?
      Ticket.all
    elsif current_user.agent_or_admin?
      Ticket.where(assigned_user_id: current_user.id)
    else
      current_user.tickets
    end
  end
end
