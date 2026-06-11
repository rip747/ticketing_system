class TicketsController < ApplicationController
  before_action :require_login
  before_action :set_ticket, only: [:show, :edit, :update, :destroy]
  before_action :require_agent_or_admin, only: [:edit, :update, :destroy, :assign]

  def index
    @tickets = Ticket.recent

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
    @ticket = Ticket.new
  end

  def create
    @ticket = current_user.tickets.build(ticket_params)
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
    @ticket = Ticket.find(params[:id])
    if @ticket.assign_to!(User.find(params[:assigned_user_id]))
      flash[:notice] = "Ticket assigned successfully."
    else
      flash[:alert] = "Could not assign ticket."
    end
    redirect_to @ticket
  end

  def close
    @ticket = Ticket.find(params[:id])
    @ticket.close!
    flash[:notice] = "Ticket closed."
    redirect_to @ticket
  end

  def reopen
    @ticket = Ticket.find(params[:id])
    @ticket.update(status: "open", closed_at: nil)
    flash[:notice] = "Ticket reopened."
    redirect_to @ticket
  end

  private

  def set_ticket
    @ticket = Ticket.find(params[:id])
  end

  def ticket_params
    params.require(:ticket).permit(:subject, :description, :priority, :category_id, :department_id)
  end
end
