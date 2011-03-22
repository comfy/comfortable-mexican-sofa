class CmsAdmin::BaseController < ActionController::Base
  
  protect_from_forgery
  
  # Authentication module must have #authenticate method
  include ComfortableMexicanSofa.config.authentication.to_s.constantize
  
  before_filter :authenticate,
                :load_admin_cms_site
  
  layout 'cms_admin'
  
protected
  
  def load_admin_cms_site
    hostname = ComfortableMexicanSofa.config.override_host || request.host.downcase
    @cms_site = CmsSite.find_by_hostname!(hostname)
  
  rescue ActiveRecord::RecordNotFound
    
    if ComfortableMexicanSofa.config.auto_manage_sites
      if CmsSite.count == 0
        @cms_site = CmsSite.create!(:label => 'Default Site', :hostname => hostname)
      elsif CmsSite.count == 1
        @cms_site = CmsSite.first
        @cms_site.update_attribute(:hostname, hostname)
      end
    end
    
    unless @cms_site
      flash[:error] = 'No Site defined for this hostname. Create it now.'
      return redirect_to(cms_admin_sites_path)
    end
  end
end
