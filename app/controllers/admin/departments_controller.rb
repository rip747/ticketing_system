module Admin
  class DepartmentsController < BaseController
    before_action :set_department, only: [ :show, :edit, :update, :destroy ]

    def index
      @departments = Department.all.order(:name)
    end

    def show
    end

    def new
      @department = Department.new
    end

    def create
      @department = Department.new(department_params)
      if @department.save
        flash[:notice] = "Department created successfully."
        redirect_to admin_departments_path
      else
        render :new, status: :unprocessable_entity
      end
    end

    def edit
    end

    def update
      if @department.update(department_params)
        flash[:notice] = "Department updated successfully."
        redirect_to admin_departments_path
      else
        render :edit, status: :unprocessable_entity
      end
    end

    def destroy
      if @department.destroy
        flash[:notice] = "Department deleted."
      else
        flash[:alert] = @department.errors.full_messages.to_sentence
      end
      redirect_to admin_departments_path
    end

    private

    def set_department
      @department = Department.find(params[:id])
    end

    def department_params
      params.require(:department).permit(:name, :description)
    end
  end
end
