class CmsAdmin::BaseController < ApplicationController
  
  protect_from_forgery
  
  # Authentication module must have #authenticate method
  include ComfortableMexicanSofa.config.authentication.to_s.constantize
  
  before_filter :authenticate,
                :load_admin_cms_site,
                :load_fixtures
  
  layout 'cms_admin'
  
  def default_url_options(options={})
    if params[:cms_locale] then
      {:cms_locale => params[:cms_locale]}
    else
      {}
    end
  end
protected
  
  def load_admin_cms_site
    hostname = if ComfortableMexicanSofa.config.enable_multiple_sites and ComfortableMexicanSofa.config.enable_i18n_sites
      request.host.downcase + ":" + (params[:cms_locale] || Rails.application.config.i18n.default_locale || I18n.locale).to_s
    else
      request.host.downcase
    end
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
  
  def load_fixtures
    return unless ComfortableMexicanSofa.config.enable_fixtures
    ComfortableMexicanSofa::Fixtures.import_all(@cms_site.hostname)
    if %w(cms_admin/layouts cms_admin/pages cms_admin/snippets).member?(params[:controller])
      flash.now[:error] = 'CMS Fixtures are enabled. All changes done here will be discarded.'
    end
  end
end
