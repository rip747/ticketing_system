class DashboardController < ApplicationController
  before_action :require_login
  before_action :redirect_sys_admin

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
    @tickets_by_department = current_organization.departments.where(id: @tickets_scope.select(:department_id))
                                        .joins(:tickets)
                                        .merge(@tickets_scope)
                                        .group(:name)
                                        .count

    @recent_tickets = @tickets_scope.recent.limit(5)
  end

  private

  def redirect_sys_admin
    if current_user&.sys_admin?
      redirect_to system_root_path
    end
  end

  def tickets_for_current_user
    if current_user.org_admin?
      current_organization.tickets
    elsif current_user.agent_or_admin?
      current_organization.tickets.where(assigned_user_id: current_user.id)
    else
      current_user.tickets
    end
  end
end
