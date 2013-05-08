class ApplicationController < ActionController::Base
  
  protect_from_forgery

  def after_sign_in_path_for(resource)
    cms_admin_path
  end
  
end
