module System
  class OrganizationsController < BaseController
    before_action :set_organization, only: [ :show, :edit, :update, :destroy ]

    def index
      @organizations = Organization.order(:name)
      @organizations = @organizations.where("name LIKE ?", "%#{params[:q]}%") if params[:q].present?
    end

    def show
      @users = @organization.users.order(:name)
      @tickets = @organization.tickets.recent.limit(20)
      @departments = @organization.departments.order(:name)
    end

    def new
      @organization = Organization.new
    end

    def create
      @organization = Organization.new(organization_params)
      if @organization.save
        flash[:notice] = "Organization created successfully."
        redirect_to system_organization_path(@organization)
      else
        render :new, status: :unprocessable_entity
      end
    end

    def edit
    end

    def update
      if @organization.update(organization_params)
        flash[:notice] = "Organization updated successfully."
        redirect_to system_organization_path(@organization)
      else
        render :edit, status: :unprocessable_entity
      end
    end

    def destroy
      if @organization.destroy
        flash[:notice] = "Organization deleted."
      else
        flash[:alert] = @organization.errors.full_messages.to_sentence
      end
      redirect_to system_organizations_path
    end

    private

    def set_organization
      @organization = Organization.find(params[:id])
    end

    def organization_params
      params.require(:organization).permit(:name, :slug)
    end
  end
end
