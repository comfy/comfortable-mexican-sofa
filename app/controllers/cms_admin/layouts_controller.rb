class CmsAdmin::LayoutsController < CmsAdmin::BaseController

  before_filter :build_cms_layout,  :only => [:new, :create]
  before_filter :load_cms_layout,   :only => [:edit, :update, :destroy]

  def index
    return redirect_to :action => :new if @cms_site.layouts.count == 0
    @cms_layouts = @cms_site.layouts.roots
  end

  def new
    render
  end

  def edit
    render
  end

  def create
    @cms_layout.save!
    flash[:notice] = 'Layout created'
    redirect_to (params[:commit] ? {:action => :index} : {:action => :edit, :id => @cms_layout})
  rescue ActiveRecord::RecordInvalid
    flash.now[:error] = 'Failed to create layout'
    render :action => :new
  end

  def update
    @cms_layout.update_attributes!(params[:cms_layout])
    flash[:notice] = 'Layout updated'
    redirect_to (params[:commit] ? {:action => :index} : {:action => :edit, :id => @cms_layout})
  rescue ActiveRecord::RecordInvalid
    flash.now[:error] = 'Failed to update layout'
    render :action => :edit
  end

  def destroy
    @cms_layout.destroy
    flash[:notice] = 'Layout deleted'
    redirect_to :action => :index
  end

protected

  def build_cms_layout
    @cms_layout = @cms_site.layouts.new(params[:cms_layout])
    @cms_layout.parent ||= Cms::Layout.find_by_id(params[:parent_id])
    @cms_layout.content ||= '{{ cms:page:content:text }}'
  end

  def load_cms_layout
    @cms_layout = @cms_site.layouts.find(params[:id])
  rescue ActiveRecord::RecordNotFound
    flash[:error] = 'Layout not found'
    redirect_to :action => :index
  end

end
