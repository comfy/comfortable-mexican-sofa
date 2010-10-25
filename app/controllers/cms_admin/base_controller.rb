class CmsAdmin::BaseController < ApplicationController
  # Authentication module must have #authenticate method
  include ComfortableMexicanSofa.config.authentication.to_s.constantize
  
  before_filter :authenticate,
                :load_admin_cms_site
  
  layout 'cms_admin'
  
protected

  def load_admin_cms_site
    @cms_site = CmsSite.find_by_hostname!(request.host.downcase)
  rescue ActiveRecord::RecordNotFound
    flash[:error] = 'No Site defined for this hostname. Create it now.'
    redirect_to new_cms_admin_site_path
  end
  
end
