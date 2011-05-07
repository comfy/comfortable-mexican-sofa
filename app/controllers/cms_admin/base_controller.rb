class CmsAdmin::BaseController < ApplicationController
  
  protect_from_forgery
  
  # Authentication module must have #authenticate method
  include ComfortableMexicanSofa.config.authentication.to_s.constantize
  
  before_filter :authenticate,
                :load_admin_cms_site
  
  layout 'cms_admin'
  
protected
  
  def load_admin_cms_site
    hostname = request.host.downcase
    @cms_site = Cms::Site.find_by_hostname!(hostname)
    
  rescue ActiveRecord::RecordNotFound
    unless ComfortableMexicanSofa.config.enable_multiple_sites
      if Cms::Site.count == 0
        @cms_site = Cms::Site.create!(:label => 'Default Site', :hostname => hostname)
      else
        @cms_site = Cms::Site.first
        @cms_site.update_attribute(:hostname, hostname)
      end
    end
    
    unless @cms_site
      flash[:error] = 'No Site defined for this hostname. Create it now.'
      return redirect_to(cms_admin_sites_path)
    end
  end
end
