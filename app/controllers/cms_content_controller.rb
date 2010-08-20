class CmsContentController < ApplicationController
  include CmsCommon::RenderPage

  unloadable

  before_filter :assign_cms_root

  def show
    #path = params[:path] || ""
    page_path = params[:path] || ""
    @cms_page = (@cms_site ? @cms_site.cms_pages : CmsPage).published.find_by_full_path(page_path)

    render_page
  end

  def sitemap
    respond_to do |format|
      format.xml do
        @cms_pages = CmsPage.published
      end
    end
  end

protected
  def assign_cms_root
    if (ComfortableMexicanSofa::Config.multiple_sites)
      @cms_site = CmsSite.find_by_hostname(request.host.downcase)
    end
  end

end
