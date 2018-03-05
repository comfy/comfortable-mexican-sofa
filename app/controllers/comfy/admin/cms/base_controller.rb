# frozen_string_literal: true

class Comfy::Admin::Cms::BaseController < Comfy::Admin::BaseController

  before_action :load_admin_site,
                :set_locale,
                :load_seeds,
                except: :jump

  layout :infer_layout

  if ComfortableMexicanSofa.config.admin_cache_sweeper.present?
    cache_sweeper(*ComfortableMexicanSofa.config.admin_cache_sweeper)
  end

  def jump
    path = ComfortableMexicanSofa.config.admin_route_redirect
    return redirect_to(path) unless path.blank?
    load_admin_site
    redirect_to comfy_admin_cms_site_pages_path(@site) if @site
  end

protected

  def load_admin_site
    id_param = params[:site_id] || session[:site_id]
    if (@site = ::Comfy::Cms::Site.find_by(id: id_param) || ::Comfy::Cms::Site.first)
      session[:site_id] = @site.id
    else
      I18n.locale = ComfortableMexicanSofa.config.admin_locale || I18n.default_locale
      flash[:danger] = I18n.t("comfy.admin.cms.base.site_not_found")
      return redirect_to(new_comfy_admin_cms_site_path)
    end
  end

  def set_locale
    I18n.locale = ComfortableMexicanSofa.config.admin_locale || (@site&.locale)
    true
  end

  def load_seeds
    return unless ComfortableMexicanSofa.config.enable_seeds

    controllers = %w[layouts pages snippets files].collect { |c| "comfy/admin/cms/" + c }
    if controllers.member?(params[:controller]) && params[:action] == "index"
      ComfortableMexicanSofa::Seeds::Importer.new(@site.identifier).import!
      flash.now[:warning] = I18n.t("comfy.admin.cms.base.seeds_enabled")
    end
  end

  def infer_layout
    false if params[:layout] == "false"
  end

end
