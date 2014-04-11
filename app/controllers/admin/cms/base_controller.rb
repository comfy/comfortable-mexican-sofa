class Admin::Cms::BaseController < ComfortableMexicanSofa.config.base_controller.to_s.constantize

  protect_from_forgery

  # Authentication module must have #authenticate method
  
  include ComfortableMexicanSofa.config.admin_auth.to_s.constantize

  before_action :load_admin_site
  before_action :authenticate,
                :set_locale,
                :load_fixtures,
                :except => :jump
  
  layout 'admin/cms'
  
  if ComfortableMexicanSofa.config.admin_cache_sweeper.present?
    cache_sweeper *ComfortableMexicanSofa.config.admin_cache_sweeper
  end
  
  def jump
    path = instance_eval &ComfortableMexicanSofa.config.admin_route_redirect
    return redirect_to(path) unless path.blank?
    redirect_to admin_cms_site_pages_path(@site) if @site
  end

  def current_ability
    @current_ability ||= Cms::Ability.new(current_admin_cms_user)
  end

  rescue_from CanCan::AccessDenied do |exception|
    redirect_to admin_cms_path, :alert => exception.message
  end
  
protected
  
  def load_admin_site
    if @site = ::Cms::Site.accessible_by(current_ability).find_by_id(params[:site_id] || session[:site_id]) || ::Cms::Site.accessible_by(current_ability).first
      session[:site_id] = @site.id
    else
      I18n.locale = ComfortableMexicanSofa.config.admin_locale || I18n.default_locale
      flash[:error] = I18n.t('cms.base.site_not_found')
      return redirect_to(new_admin_cms_site_path)
    end
  end

  def set_locale
    I18n.locale = ComfortableMexicanSofa.config.admin_locale || (@site && @site.locale)
    true
  end

  def load_fixtures
    return unless ComfortableMexicanSofa.config.enable_fixtures
    if %w(admin/cms/layouts admin/cms/pages admin/cms/snippets).member?(params[:controller])
      ComfortableMexicanSofa::Fixture::Importer.new(@site.identifier).import!
      flash.now[:error] = I18n.t('cms.base.fixtures_enabled')
    end
  end

end
