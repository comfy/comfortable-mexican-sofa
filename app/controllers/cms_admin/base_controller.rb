class CmsAdmin::BaseController < ApplicationController
  
  protect_from_forgery
  
  # Authentication module must have #authenticate method
  include ComfortableMexicanSofa.config.authentication.to_s.constantize
  
  before_filter :authenticate,
                :load_admin_site,
                :load_fixtures,
                :except => :jump
  
  layout 'cms_admin'
  
  def jump
    path = ComfortableMexicanSofa.config.admin_route_redirect
    return redirect_to(path) unless path.blank?
    load_admin_site
    redirect_to cms_admin_site_pages_path(@site)
  end
  
protected
  
  def load_admin_site
    @site = Cms::Site.find(params[:site_id])
  rescue ActiveRecord::RecordNotFound => e
    raise e unless @site = Cms::Site.first
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
