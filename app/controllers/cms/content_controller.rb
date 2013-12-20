class Cms::ContentController < Cms::BaseController

  respond_to :json, :html

  # Authentication module must have #authenticate method
  include ComfortableMexicanSofa.config.public_auth.to_s.constantize

  before_action :load_fixtures
  before_action :authenticate,
                :only => :show

  rescue_from ActiveRecord::RecordNotFound, :with => :page_not_found

  def show
    @cms_page = @cms_site.pages.published.find_by_full_path!("/#{params[:cms_path]}")

    if @cms_page.target_page.present?
      redirect_to @cms_page.target_page.url
    else
      respond_with(@cms_page) do |format|
        format.html { render_html }
      end
    end
  end

  def render_sitemap
    render
  end

protected

  def render_html(status = 200)
    if @cms_layout = @cms_page.layout
      app_layout = (@cms_layout.app_layout.blank? || request.xhr?) ? false : @cms_layout.app_layout
      render :inline => @cms_page.content, :layout => app_layout, :status => status, :content_type => 'text/html'
    else
      render :text => I18n.t('cms.content.layout_not_found'), :status => 404
    end
  end

  def load_fixtures
    return unless ComfortableMexicanSofa.config.enable_fixtures
    ComfortableMexicanSofa::Fixture::Importer.new(@cms_site.identifier).import!
  end

  def page_not_found
    @cms_page = @cms_site.pages.published.find_by_full_path!('/404')

    respond_with @cms_page do |format|
      format.html { render_html(404) }
    end

  rescue ActiveRecord::RecordNotFound
    raise ActionController::RoutingError.new("Page Not Found at: \"#{params[:cms_path]}\"")
  end
end