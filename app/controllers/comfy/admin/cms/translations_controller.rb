# frozen_string_literal: true

class Comfy::Admin::Cms::TranslationsController < Comfy::Admin::Cms::BaseController
  helper_method :translation_select_options

  before_action :load_page
  before_action :build_translation,   only: %i[new create]
  before_action :load_translation,    only: %i[edit update destroy]
  before_action :authorize
  before_action :preview_translation, only: %i[create update]

  def new
    render
  end

  def edit
    render
  end

  def create
    @translation.save!
    flash[:success] = I18n.t('comfy.admin.cms.translations.created')
    redirect_to action: :edit, id: @translation
  rescue ActiveRecord::RecordInvalid
    flash.now[:danger] = I18n.t('comfy.admin.cms.translations.creation_failure')
    render action: :new
  end

  def update
    @translation.update!(translation_params)
    flash[:success] = I18n.t('comfy.admin.cms.translations.updated')
    redirect_to action: :edit, id: @translation
  rescue ActiveRecord::RecordInvalid
    flash.now[:danger] = I18n.t('comfy.admin.cms.translations.update_failure')
    render action: :edit
  end

  def destroy
    @translation.destroy
    flash[:success] = I18n.t('comfy.admin.cms.translations.deleted')
    redirect_to edit_comfy_admin_cms_site_page_path(@site, @page)
  end

  def form_fragments
    @translation = @page.translations.find_by(id: params[:id]) || @page.translations.new
    @translation.layout = @site.layouts.find_by(id: params[:layout_id])

    render(
      partial: 'comfy/admin/cms/fragments/form_fragments',
      locals: { record: @translation, scope: :translation },
      layout: false
    )
  end

private

  def translation_select_options
    all = ComfortableMediaSurfer.config.locales
    taken = @page.translations.pluck(:locale) + [@site.locale] - [@translation.locale]
    all.except(*taken).map { |k, v| ["#{v} (#{k})", k] }
  end

  def load_page
    @page = @site.pages.find(params[:page_id])
  rescue ActiveRecord::RecordNotFound
    flash[:danger] = I18n.t('comfy.admin.cms.pages.not_found')
    redirect_to comfy_admin_cms_site_pages_path(@site)
  end

  def build_translation
    @translation = @page.translations.new(translation_params)
    @translation.layout ||= @page.layout
  end

  def load_translation
    @translation = @page.translations.find(params[:id])
    @translation.attributes = translation_params
  rescue ActiveRecord::RecordNotFound
    flash[:danger] = I18n.t('comfy.admin.cms.translations.not_found')
    redirect_to edit_comfy_admin_cms_site_page_path(@site, @page)
  end

  def translation_params
    params.fetch(:translation, {}).permit!
  end

  def preview_translation
    return unless params[:preview]

    layout = @translation.layout.app_layout.blank? ? false : @translation.layout.app_layout
    @cms_site   = @page.site
    @cms_layout = @translation.layout
    @cms_page   = @page

    # Make sure to use the site locale to render the preview becaue it might
    # be different from the admin locale.
    I18n.locale = @translation.locale

    # Chrome chokes on content with iframes. Issue #434
    response.headers['X-XSS-Protection'] = '0'

    # raise
    render inline: @translation.render, layout: layout, content_type: 'text/html'
  end
end
