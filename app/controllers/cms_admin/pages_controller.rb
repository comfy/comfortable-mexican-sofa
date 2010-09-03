class CmsAdmin::PagesController < CmsAdmin::BaseController
  before_filter :build_cms_page, :only => [:new, :create]
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
    @cms_page.save!
    flash[:notice] = 'Page saved'
    redirect_to :action => :edit, :id => @cms_page
  rescue ActiveRecord::RecordInvalid
    render :action => :new
  end
  
  def update
    # TODO
  end
  
  def form_blocks
    @cms_page = CmsPage.find_by_id(params[:id]) || CmsPage.new
    @cms_page.cms_layout = CmsLayout.find_by_id(params[:layout_id])
  end
  
protected
  
  def build_cms_page
    @cms_page = CmsPage.new(params[:cms_page])
    @cms_page.parent ||= CmsPage.find_by_id(params[:parent_id])
    @cms_page.cms_layout ||= CmsLayout.first
  end
  
  def load_cms_page
    @cms_page = CmsPage.find(params[:id])
  rescue ActiveRecord::RecordNotFound
    flash[:error] = 'Page not found'
    redirect_to :action => :index
  end
  
end
