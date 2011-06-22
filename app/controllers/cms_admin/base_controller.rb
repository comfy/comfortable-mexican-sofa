class CmsAdmin::BaseController < ApplicationController
  
  protect_from_forgery
  
  # Authentication module must have #authenticate method
  include ComfortableMexicanSofa.config.authentication.to_s.constantize
  
  before_filter :authenticate,
                :load_admin_site,
                :load_fixtures
  
  layout 'cms_admin'
  
  def jump
    
  end
  
protected
  
  def load_admin_site
    @site = Cms::Site.find(params[:site_id])
  rescue ActiveRecord::RecordNotFound
    flash[:error] = 'Site not found'
    return redirect_to(cms_admin_sites_path)
  end
  
  def load_fixtures
    return unless ComfortableMexicanSofa.config.enable_fixtures
    ComfortableMexicanSofa::Fixtures.import_all(@site.hostname)
    if %w(cms_admin/layouts cms_admin/pages cms_admin/snippets).member?(params[:controller])
      flash.now[:error] = 'CMS Fixtures are enabled. All changes done here will be discarded.'
    end
  end
end
