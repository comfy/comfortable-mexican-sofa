class CmsAdmin::SessionsController < ::Devise::SessionsController
  layout "cms_admin"
  # the rest is inherited, so it should work

  def after_sign_in_path_for(resource)
    cms_admin_path
  end
end
