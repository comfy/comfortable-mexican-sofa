class CmsAdmin::PagesController < CmsAdmin::BaseController

  before_filter :check_for_layouts, :only => [:new, :edit]
  before_filter :build_cms_page,    :only => [:new, :create]
  before_filter :load_cms_page,     :only => [:edit, :update, :destroy]
  before_filter :preview_cms_page,  :only => [:create, :update]
  before_filter :build_upload_file, :only => [:new, :edit]

  def index
    return redirect_to :action => :new if @cms_site.pages.count == 0
    @cms_pages = [@cms_site.pages.root].compact
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
    redirect_to (params[:commit] ? {:action => :index} : {:action => :edit, :id => @cms_page})
  rescue ActiveRecord::RecordInvalid
    flash.now[:error] = 'Failed to create page'
    render :action => :new
  end

  def update
    @cms_page.save!
    flash[:notice] = 'Page updated'
    redirect_to (params[:commit] ? {:action => :index} : {:action => :edit, :id => @cms_page})
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
    @cms_page = @cms_site.pages.find_by_id(params[:id]) || @cms_site.pages.new
    @cms_page.layout = @cms_site.layouts.find_by_id(params[:layout_id])
  end

  def toggle_branch
    @cms_page = @cms_site.pages.find(params[:id])
    s   = (session[:cms_page_tree] ||= [])
    id  = @cms_page.id.to_s
    s.member?(id) ? s.delete(id) : s << id
  rescue ActiveRecord::RecordNotFound
    # do nothing
  end

  def reorder
    (params[:cms_page] || []).each_with_index do |id, index|
      if (cms_page = Cms::Page.find_by_id(id))
        cms_page.update_attribute(:position, index)
      end
    end
    render :nothing => true
  end

protected

  def check_for_layouts
    if @cms_site.layouts.count == 0
      flash[:error] = 'No Layouts found. Please create one.'
      redirect_to new_cms_admin_layout_path
    end
  end

  def build_cms_page
    @cms_page = @cms_site.pages.new(params[:cms_page])
    @cms_page.parent ||= (@cms_site.pages.find_by_id(params[:parent_id]) || @cms_site.pages.root)
    @cms_page.layout ||= (@cms_page.parent && @cms_page.parent.layout || @cms_site.layouts.first)
  end

  def build_upload_file
    @upload = Cms::Upload.new
  end

  def load_cms_page
    @cms_page = @cms_site.pages.find(params[:id])
    @cms_page.attributes = params[:cms_page]
    @cms_page.layout ||= (@cms_page.parent && @cms_page.parent.layout || @cms_site.layouts.first)
  rescue ActiveRecord::RecordNotFound
    flash[:error] = 'Page not found'
    redirect_to :action => :index
  end

  def preview_cms_page
    if params[:preview]
      layout = @cms_page.layout.app_layout.blank?? false : @cms_page.layout.app_layout
      render :inline => @cms_page.content(true), :layout => layout
    end
  end
end
