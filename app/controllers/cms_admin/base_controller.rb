class CmsAdmin::BaseController < ApplicationController

  protect_from_forgery

  # Authentication module must have #authenticate method
  include ComfortableMexicanSofa.config.admin_auth.to_s.constantize

  before_filter :authenticate,
                :load_admin_site,
                :set_locale,
                :load_fixtures,
                :except => :jump
  
  layout 'cms_admin'
  
  if ComfortableMexicanSofa.config.admin_cache_sweeper.present?
    cache_sweeper *ComfortableMexicanSofa.config.admin_cache_sweeper
  end
  
  def jump
    path = ComfortableMexicanSofa.config.admin_route_redirect
    return redirect_to(path) unless path.blank?
    load_admin_site
    redirect_to cms_admin_site_pages_path(@site) if @site
  end

  def current_ability
    @current_ability ||= Cms::Ability.new(current_cms_admin_user)
  end

  rescue_from CanCan::AccessDenied do |exception|
    redirect_to cms_admin_sites_path, :alert => exception.message
  end
  
protected
  
  def load_admin_site
    if @site = Cms::Site.accessible_by(current_ability).find_by_id(params[:site_id] || session[:site_id]) || Cms::Site.accessible_by(current_ability).first
      session[:site_id] = @site.id
    else
      I18n.locale = ComfortableMexicanSofa.config.admin_locale || I18n.default_locale
      flash[:error] = I18n.t('cms.base.site_not_found')
      return redirect_to(new_cms_admin_site_path)
    end
  end

  def set_locale
    I18n.locale = ComfortableMexicanSofa.config.admin_locale || (@site && @site.locale)
    true
  end

  def load_fixtures
    return unless ComfortableMexicanSofa.config.enable_fixtures
    if %w(cms_admin/layouts cms_admin/pages cms_admin/snippets).member?(params[:controller])
      ComfortableMexicanSofa::Fixtures.import_all(@site.identifier)
      flash.now[:error] = I18n.t('cms.base.fixtures_enabled')
    end
  end
end
