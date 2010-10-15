class CmsAdmin::PagesController < CmsAdmin::BaseController
  
  before_filter :build_cms_page,  :only => [:new, :create]
  before_filter :load_cms_page,   :only => [:edit, :update, :destroy]
  
  def index
    @cms_pages = [@cms_site.cms_pages.root].compact
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
    flash.now[:error] = 'Failed to create page'
    render :action => :new
  end
  
  def update
    @cms_page.update_attributes!(params[:cms_page])
    flash[:notice] = 'Page updated'
    redirect_to :action => :edit, :id => @cms_page
  rescue ActiveRecord::RecordInvalid
    flash.now[:error] = 'Failed to update page'
    render :action => :edit
  end
  
  def destroy
    @cms_page.destroy
    flash[:notice] = 'Page deleted'
    redirect_to :action => :index
  end
  
  def form_blocks
    @cms_page = @cms_site.cms_pages.find_by_id(params[:id]) || CmsPage.new
    @cms_page.cms_layout = @cms_site.cms_layouts.find_by_id(params[:layout_id])
  end
  
protected
  
  def build_cms_page
    @cms_page = @cms_site.cms_pages.new(params[:cms_page])
    @cms_page.parent ||= (CmsPage.find_by_id(params[:parent_id]) || @cms_site.cms_pages.root)
    @cms_page.cms_layout ||= (@cms_page.parent && @cms_page.parent.cms_layout || @cms_site.cms_layouts.first)
  end
  
  def load_cms_page
    @cms_page = @cms_site.cms_pages.find(params[:id])
    @cms_page.cms_layout ||= (@cms_page.parent && @cms_page.parent.cms_layout || @cms_site.cms_layouts.first)
  rescue ActiveRecord::RecordNotFound
    flash[:error] = 'Page not found'
    redirect_to :action => :index
  end
  
end
