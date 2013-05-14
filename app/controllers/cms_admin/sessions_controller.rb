class CmsAdmin::SessionsController < ::Devise::SessionsController
  layout "cms_admin"
  
  # Public: Sign the user out
  def destroy
    # Clear their site ID.
    session[:site_id] = nil
    super
  end

  def after_sign_in_path_for(resource)
    cms_admin_path
  end
end
