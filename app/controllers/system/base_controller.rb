module System
  class BaseController < ApplicationController
    before_action :require_sys_admin
    layout "system"

    private

    def require_sys_admin
      unless current_user&.sys_admin?
        flash[:alert] = "You are not authorized to access the System Administration panel."
        redirect_to system_login_path
      end
    end
  end
end
