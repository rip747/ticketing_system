module System
  class SessionsController < ApplicationController
    layout "system"

    def new
      redirect_to system_root_path if current_user&.sys_admin?
    end

    def create
      user = User.find_by(email: params[:email])

      if user&.sys_admin? && user.authenticate(params[:password])
        session[:user_id] = user.id
        session[:sys_admin] = true
        flash[:notice] = "Welcome, #{user.name}!"
        redirect_to system_root_path
      elsif user&.authenticate(params[:password])
        flash.now[:alert] = "This login is for System Administrators only. Use the regular login if you are a regular user."
        render :new, status: :unprocessable_entity
      else
        flash.now[:alert] = "Invalid email or password."
        render :new, status: :unprocessable_entity
      end
    end

    def destroy
      session[:user_id] = nil
      session[:sys_admin] = nil
      flash[:notice] = "You have been logged out."
      redirect_to system_login_path
    end
  end
end
