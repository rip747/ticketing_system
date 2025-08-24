class ApplicationController < ActionController::Base
  # Only allow modern browsers supporting webp images, web push, badges, import maps, CSS nesting, and CSS :has.
  allow_browser versions: :modern

  before_action :authenticate_user
  helper_method :current_user

  private

  def authenticate_user
    redirect_to new_session_path, alert: "Please log in" unless current_user
  end

  def current_user
    @current_user ||= User.find_by(id: session[:user_id], tenant_id: Current.tenant_id)
  end
end
