class DepartmentsController < ApplicationController
  def categories
    department = Department.find(params[:id])
    categories = department.categories.select(:id, :name)
    render json: categories
  end
end
