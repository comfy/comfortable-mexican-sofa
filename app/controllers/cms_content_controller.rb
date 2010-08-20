class CmsContentController < ApplicationController
  include CmsCommon::RenderPage

  unloadable

  def show
    page_path = params[:path] || ""
    @cms_page = CmsPage.published.find_by_full_path(page_path)

    render_page
  end

  def sitemap
    respond_to do |format|
      format.xml do
        @cms_pages = CmsPage.published
      end
    end
  end

end
