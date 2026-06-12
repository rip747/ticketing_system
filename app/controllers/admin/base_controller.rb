module Admin
  class BaseController < ApplicationController
    before_action :require_org_admin
    layout "admin"
  end
end
