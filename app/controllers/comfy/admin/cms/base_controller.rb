# frozen_string_literal: true

class Comfy::Admin::Cms::BaseController < Comfy::Admin::BaseController
  before_action :load_admin_site,
                :set_locale,
                :load_seeds,
                except: :jump

  layout :infer_layout

  if ComfortableMediaSurfer.config.admin_cache_sweeper.present?
    cache_sweeper(*ComfortableMediaSurfer.config.admin_cache_sweeper)
  end

  def jump
    path = ComfortableMediaSurfer.config.admin_route_redirect
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
      I18n.locale = ComfortableMediaSurfer.config.admin_locale || I18n.default_locale
      flash[:danger] = I18n.t('comfy.admin.cms.base.site_not_found')
      redirect_to(new_comfy_admin_cms_site_path)
    end
  end

  def set_locale
    I18n.locale = ComfortableMediaSurfer.config.admin_locale || @site&.locale
    true
  end

  def load_seeds
    return unless ComfortableMediaSurfer.config.enable_seeds

    controllers = %w[layouts pages snippets files].collect { |c| "comfy/admin/cms/#{c}" }
    return unless controllers.member?(params[:controller]) && params[:action] == 'index'

    ComfortableMediaSurfer::Seeds::Importer.new(@site.identifier).import!
    flash.now[:warning] = I18n.t('comfy.admin.cms.base.seeds_enabled')
  end

  def infer_layout
    false if params[:layout] == 'false'
  end
end
