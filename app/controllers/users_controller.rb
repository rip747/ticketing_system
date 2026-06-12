class UsersController < ApplicationController
  before_action :require_login, only: [ :show, :edit, :update ]
  before_action :set_user, only: [ :show, :edit, :update ]

  def new
    @user = User.new
  end

  def create
    org_name = params[:user][:organization_name]
    @organization = Organization.new(name: org_name)

    if org_name.blank?
      @organization.errors.add(:name, "can't be blank")
      @user = @organization.users.build(user_params)
      @user.role = "org_admin"
      render :new, status: :unprocessable_entity
      return
    end

    ActiveRecord::Base.transaction do
      @organization.save!
      @user = @organization.users.build(user_params)
      @user.role = "org_admin"
      @user.save!
    end

    session[:user_id] = @user.id
    flash[:notice] = "Organization created successfully! Welcome, #{@user.name}."
    redirect_to root_path

  rescue ActiveRecord::RecordInvalid
    # Collect errors from both models
    @user ||= @organization.users.build(user_params)
    @user.role = "org_admin"
    @user.validate
    # Merge organization errors into user for display
    @organization.errors.full_messages.each do |msg|
      @user.errors.add(:base, msg) unless @user.errors.full_messages.include?(msg)
    end
    render :new, status: :unprocessable_entity
  end

  def show
  end

  def edit
  end

  def update
    if @user.update(update_params)
      flash[:notice] = "Profile updated successfully."
      redirect_to profile_path
    else
      render :edit, status: :unprocessable_entity
    end
  end

  private

  def set_user
    @user = current_user
  end

  def user_params
    params.require(:user).permit(:name, :email, :password, :password_confirmation)
  end

  def update_params
    params.require(:user).permit(:name, :email, :password, :password_confirmation, :department_id)
  end
end
