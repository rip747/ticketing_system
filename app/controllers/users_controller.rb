class UsersController < ApplicationController
  skip_before_action :authenticate_user, only: [ :new, :create ]
  before_action :set_current_tenant

  def new
    @user = User.new
  end

  def create
    @user = User.new(user_params)
    @user.tenant_id = Current.tenant_id
    if @user.save
      session[:user_id] = @user.id
      redirect_to tickets_path, notice: "Account created and signed in!"
    else
      render :new
    end
  end

  private

  def set_current_tenant
    Current.tenant_id = Tenant.find_by(subdomain: request.subdomain)&.id
    redirect_to root_path, alert: "Invalid tenant" unless Current.tenant_id
  end

  def user_params
    params.require(:user).permit(:email, :password, :password_confirmation)
  end
end
