class CmsAdmin::SessionsController < ::Devise::SessionsController
  layout "cms_admin"
  # the rest is inherited, so it should work
end
