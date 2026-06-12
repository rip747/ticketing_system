class ApplicationController < ActionController::Base
  # Only allow modern browsers supporting webp images, web push, badges, import maps, CSS nesting, and CSS :has.
  allow_browser versions: :modern

  # Changes to the importmap will invalidate the etag for HTML responses
  stale_when_importmap_changes

  helper_method :current_user, :current_organization, :logged_in?

  around_action :scope_to_organization

  private

  def current_user
    @current_user ||= User.find_by(id: session[:user_id]) if session[:user_id]
  end

  def current_organization
    return nil if current_user&.sys_admin?
    @current_organization ||= current_user&.organization
  end

  def logged_in?
    current_user.present?
  end

  def require_login
    unless logged_in?
      flash[:alert] = "Please log in to continue."
      redirect_to login_path
    end
  end

  def require_org_admin
    unless current_user&.org_admin?
      flash[:alert] = "You are not authorized to perform this action."
      redirect_to root_path
    end
  end

  def require_agent_or_admin
    unless current_user&.agent_or_admin?
      flash[:alert] = "You are not authorized to perform this action."
      redirect_to root_path
    end
  end

  def scope_to_organization
    if current_organization
      Current.set(organization: current_organization) { yield }
    else
      yield
    end
  end
end
