# frozen_string_literal: true

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

  def show
    if @cms_page.target_page.present?
      redirect_to @cms_page.target_page.url(relative: true)
    else
      respond_to do |format|
        format.html { render_page }
        format.json do
          json_page = @cms_page.as_json(except: [:content_cache])
          json_page[:content] = render_to_string(
            inline: @cms_page.content_cache,
            layout: false
          )
          render json: json_page
        end
      end
    end
  end

protected

  def render_page(status = :ok)
    render  inline:       @cms_page.content_cache,
            layout:       app_layout,
            status:       status,
            content_type: mime_type
  end

  # it's possible to control mimetype of a page by creating a `mime_type` field
  def mime_type
    mime_block = @cms_page.fragments.detect { |f| f.identifier == "mime_type" }
    mime_block&.content&.strip || "text/html"
  end

  def app_layout
    return false if request.xhr? || !@cms_layout
    @cms_layout.app_layout.present? ? @cms_layout.app_layout : false
  end

  def load_seeds
    return unless ComfortableMexicanSofa.config.enable_seeds
    ComfortableMexicanSofa::Seeds::Importer.new(@cms_site.identifier).import!
  end

  # Attempting to populate @cms_page and @cms_layout instance variables so they
  # can be used in view helpers/partials
  def load_cms_page
    unless find_cms_page_by_full_path("/#{params[:cms_path]}")
      if find_cms_page_by_full_path("/404")
        render_page(:not_found)
      else
        message = "Page Not Found at: \"#{params[:cms_path]}\""
        raise ActionController::RoutingError, message
      end
    end
  end

  # Getting page and setting content_cache and fragments data if we need to
  # serve translation data
  def find_cms_page_by_full_path(full_path)
    @cms_page   = @cms_site.pages.published.find_by!(full_path: full_path)
    @cms_layout = @cms_page.layout

    # There are translations for this page and locale is not the default site
    # locale, so we need to grab translation data.
    if @cms_page.translations.any? && @cms_site.locale != I18n.locale.to_s
      @cms_page.translate!(I18n.locale)
      @cms_layout = @cms_page.layout
    end

    @cms_page

  rescue ActiveRecord::RecordNotFound
    nil
  end

end
