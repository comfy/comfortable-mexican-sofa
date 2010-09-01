class CmsAdmin::PagesController < CmsAdmin::BaseController
  before_filter :build_cms_page, :only => [:new]
  before_filter :load_cms_page, :only => [:edit]
  
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
    @cms_page = CmsPage.new(params[:cms_page])
    @cms_page.save!
    flash[:notice] = 'Page saved'
    redirect_to :action => :edit, :id => @cms_page
  rescue ActiveRecord::RecordInvalid
    render :action => :new
  end
  
  def update
    # TODO
  end
  
protected
  
  def build_cms_page
    @cms_page = CmsPage.new(params[:cms_page])
    @cms_page.cms_layout ||= CmsLayout.first
    @cms_page.initialize_tags
  end
  
  def load_cms_page
    @cms_page = CmsPage.find(params[:id])
    @cms_page.initialize_tags
  rescue ActiveRecord::RecordNotFound
    flash[:error] = 'Page not found'
    redirect_to :action => :index
  end
  
end
