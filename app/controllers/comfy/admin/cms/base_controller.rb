class Comfy::Admin::Cms::BaseController < ComfortableMexicanSofa.config.base_controller.to_s.constantize

  protect_from_forgery

  # Authentication module must have #authenticate method
  include ComfortableMexicanSofa.config.admin_auth.to_s.constantize

  before_action :authenticate,
                :load_admin_site,
                :set_locale,
                :load_fixtures,
                :except => :jump
  
  layout 'comfy/admin/cms'
  
  if ComfortableMexicanSofa.config.admin_cache_sweeper.present?
    cache_sweeper *ComfortableMexicanSofa.config.admin_cache_sweeper
  end
  
  def jump
    path = ComfortableMexicanSofa.config.admin_route_redirect
    return redirect_to(path) unless path.blank?
    load_admin_site
    redirect_to admin_cms_site_pages_path(@site) if @site
  end
  
protected
  
  def load_admin_site
    if @site = ::Comfy::Cms::Site.find_by_id(params[:site_id] || session[:site_id]) || ::Comfy::Cms::Site.first
      session[:site_id] = @site.id
    else
      I18n.locale = ComfortableMexicanSofa.config.admin_locale || I18n.default_locale
      flash[:error] = I18n.t('comfy.admin.cms.base.site_not_found')
      return redirect_to(new_admin_cms_site_path)
    end
  end

  def set_locale
    I18n.locale = ComfortableMexicanSofa.config.admin_locale || (@site && @site.locale)
    true
  end

  def load_fixtures
    return unless ComfortableMexicanSofa.config.enable_fixtures
    controllers = %w(comfy/admin/cms/layouts comfy/admin/cms/pages comfy/admin/cms/snippets)
    if controllers.member?(params[:controller])
      ComfortableMexicanSofa::Fixture::Importer.new(@site.identifier).import!
      flash.now[:error] = I18n.t('comfy.admin.cms.base.fixtures_enabled')
    end
  end
end
