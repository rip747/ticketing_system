class SessionsController < ApplicationController
  def new
  end

  def create
    tenant = Tenant.find_by(subdomain: request.subdomain)
    user = User.find_by(email: params[:email], tenant_id: tenant&.id)
    if user&.authenticate(params[:password])
      session[:user_id] = user.id
      redirect_to tickets_path, notice: "Logged in successfully"
    else
      flash.now[:alert] = "Invalid email or password"
      render :new
    end
  end

  def destroy
    session[:user_id] = nil
    redirect_to login_path, notice: "Logged out"
  end
end
