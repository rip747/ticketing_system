class TicketsController < ApplicationController
  before_action :require_login
  before_action :set_ticket, only: [ :show, :edit, :update, :destroy, :assign, :close, :reopen ]
  before_action :require_agent_or_admin, only: [ :edit, :update, :destroy, :assign ]

  def index
    @tickets = current_organization.tickets.recent

    if current_user.customer?
      @tickets = @tickets.where(user_id: current_user.id)
    end

    @tickets = @tickets.by_status(params[:status]) if params[:status].present?
    @tickets = @tickets.by_priority(params[:priority]) if params[:priority].present?
    @tickets = @tickets.by_department(params[:department_id]) if params[:department_id].present?

    if params[:q].present?
      @tickets = @tickets.where("subject LIKE ? OR description LIKE ?", "%#{params[:q]}%", "%#{params[:q]}%")
    end

    @tickets = @tickets.includes(:user, :assigned_user, :category, :department)
  end

  def show
    @comment = Comment.new
    @comments = @ticket.comments.recent.includes(:user)
  end

  def new
    @ticket = current_organization.tickets.new
  end

  def create
    @ticket = current_organization.tickets.build(ticket_params)
    @ticket.user = current_user
    @ticket.status = "open"

    if @ticket.save
      flash[:notice] = "Ticket created successfully."
      redirect_to @ticket
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit
  end

  def update
    if @ticket.update(ticket_params)
      flash[:notice] = "Ticket updated successfully."
      redirect_to @ticket
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @ticket.destroy
    flash[:notice] = "Ticket deleted."
    redirect_to tickets_path
  end

  def assign
    if @ticket.assign_to!(current_organization.users.find(params[:assigned_user_id]))
      flash[:notice] = "Ticket assigned successfully."
    else
      flash[:alert] = "Could not assign ticket."
    end
    redirect_to @ticket
  end

  def close
    @ticket.close!
    flash[:notice] = "Ticket closed."
    redirect_to @ticket
  end

  def reopen
    @ticket.update(status: "open", closed_at: nil)
    flash[:notice] = "Ticket reopened."
    redirect_to @ticket
  end

  private

  def set_ticket
    @ticket = current_organization.tickets.find(params[:id])
  end

  def ticket_params
    params.require(:ticket).permit(:subject, :description, :priority, :category_id, :department_id)
  end
end
