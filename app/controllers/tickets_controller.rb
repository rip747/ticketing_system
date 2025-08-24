class TicketsController < ApplicationController
  before_action :authenticate_user
  before_action :set_current_tenant

  def index
    @tickets = Ticket.all
    respond_to do |format|
      format.html
      format.json { render json: { success: true, data: @tickets } }
    end
  end

  def show
    @ticket = Ticket.find(params[:id])
    respond_to do |format|
      format.html
      format.json { render json: { success: true, data: @ticket } }
    end
  end

  def new
    @ticket = Ticket.new
  end

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
