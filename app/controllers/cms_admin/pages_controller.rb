class CmsAdmin::PagesController < CmsAdmin::BaseController
  
  before_filter :build_cms_page, :only => [:new]
  
  def index
    @cms_pages = CmsPage
  end
  
  def new
    render
  end
  
  def edit
    render
  end
  
  def create
    
  end

protected

  def build_cms_page
    @cms_page = CmsPage.new(params[:cms_page])
    @cms_page.cms_layout = CmsLayout.first
    CmsTag.initialize_tags(@cms_page.cms_layout.content, :cms_page => @cms_page)
  end

end
