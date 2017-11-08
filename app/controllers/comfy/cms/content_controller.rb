class Comfy::Cms::ContentController < Comfy::Cms::BaseController

  # Authentication module must have `authenticate` method
  include ComfortableMexicanSofa.config.public_auth.to_s.constantize

  # Authorization module must have `authorize` method
  include ComfortableMexicanSofa.config.public_authorization.to_s.constantize

  before_action :load_seeds
  before_action :load_cms_page,
                :authenticate,
                :authorize,
                only: :show

  rescue_from ActiveRecord::RecordNotFound, with: :page_not_found

  def show
    if @cms_page.target_page.present?
      redirect_to @cms_page.target_page.url(:relative)
    else
      respond_to do |format|
        format.html { render_page }
        format.json { render json: @cms_page }
      end
    end
  end

protected

  def render_page(status = 200)
    if @cms_layout
      app_layout = (@cms_layout.app_layout.blank? || request.xhr?) ? false : @cms_layout.app_layout
      render  inline:       @cms_content_cache,
              layout:       app_layout,
              status:       status,
              content_type: mime_type
    else
      render plain: I18n.t('comfy.cms.content.layout_not_found'), status: 404
    end
  end

  # it's possible to control mimetype of a page by creating a `mime_type` field
  def mime_type
    mime_block = @cms_page.fragments.find_by(identifier: :mime_type)
    mime_block && mime_block.content || 'text/html'
  end

  def load_seeds
    return unless ComfortableMexicanSofa.config.enable_seeds
    ComfortableMexicanSofa::Seeds::Importer.new(@cms_site.identifier).import!
  end

  def load_cms_page
    @cms_page = @cms_site.pages.published.find_by!(full_path: "/#{params[:cms_path]}")

    if @cms_page.translations.any? && @cms_site.locale != I18n.locale.to_s
      translation = @cms_page.translations.published.find_by!(locale: I18n.locale)
      @cms_content_cache  = translation.content_cache
      @cms_layout         = translation.layout
      I18n.locale = @locale = I18n.locale.to_sym

    else
      @cms_content_cache  = @cms_page.content_cache
      @cms_layout         = @cms_page.layout
      I18n.locale = @locale = @cms_site.locale.to_sym
    end
  end

  def page_not_found
    @cms_page   = @cms_site.pages.published.find_by!(full_path: "/404")
    @cms_layout         = @cms_page.layout
    @cms_content_cache  = @cms_page.content_cache

    respond_to do |format|
      format.html { render_page(404) }
    end
  rescue ActiveRecord::RecordNotFound
    raise ActionController::RoutingError.new("Page Not Found at: \"#{params[:cms_path]}\"")
  end
end
