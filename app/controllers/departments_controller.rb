class DepartmentsController < ApplicationController
  before_action :require_login

  def categories
    department = current_organization.departments.find(params[:id])
    categories = department.categories.select(:id, :name)
    render json: categories
  end
end
