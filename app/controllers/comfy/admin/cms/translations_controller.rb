class Comfy::Admin::Cms::TranslationsController < Comfy::Admin::Cms::BaseController

  helper_method :translation_select_options

  before_action :load_page
  before_action :build_translation, only: [:new, :create]
  before_action :load_translation,  only: [:edit, :update, :destroy]

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
    @translation.update_attributes!(translation_params)
    flash[:success] = I18n.t('comfy.admin.cms.translations.updated')
    redirect_to action: :edit, id: @translation
  rescue ActiveRecord::RecordInvalid
    flash.now[:danger] = I18n.t('comfy.admin.cms.translations.update_failure')
    render action: :edit
  end

  def destroy
    @translation.destroy
    flash[:success] = I18n.t('comfy.admin.cms.translations.deleted')
    redirect_to comfy_admin_cms_site_page_path(@site, @page)
  end

private

  def translation_select_options
    all = ComfortableMexicanSofa.config.locales
    taken = @page.translations.pluck(:locale) + [@site.locale] - [@translation.locale]
    all.except(*taken).map{|k, v| ["#{v} (#{k})", k]}
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
  rescue ActiveRecord::RecordNotFound
    flash[:danger] = I18n.t('comfy.admin.cms.translations.not_found')
    redirect_to edit_comfy_admin_cms_site_page_path(@site, @page)
  end

  def translation_params
    params.fetch(:translation, {}).permit!
  end
end
