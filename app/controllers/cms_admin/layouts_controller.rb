class CmsAdmin::LayoutsController < CmsAdmin::BaseController

  before_filter :build_layout,  :only => [:new, :create]
  before_filter :load_layout,   :only => [:edit, :update, :destroy]

  def index
    return redirect_to :action => :new if @site.layouts.count == 0
    @layouts = @site.layouts.roots
  end

  def new
    render
  end

  def edit
    render
  end

  def create
    @layout.save!
    flash[:notice] = 'Layout created'
    redirect_to :action => :edit, :id => @layout
  rescue ActiveRecord::RecordInvalid
    flash.now[:error] = 'Failed to create layout'
    render :action => :new
  end

  def update
    @layout.update_attributes!(params[:layout])
    flash[:notice] = 'Layout updated'
    redirect_to :action => :edit, :id => @layout
  rescue ActiveRecord::RecordInvalid
    flash.now[:error] = 'Failed to update layout'
    render :action => :edit
  end

  def destroy
    @layout.destroy
    flash[:notice] = 'Layout deleted'
    redirect_to :action => :index
  end

protected

  def build_layout
    @layout = @site.layouts.new(params[:layout])
    @layout.parent  ||= Cms::Layout.find_by_id(params[:parent_id])
    @layout.content ||= '{{ cms:page:content:text }}'
  end

  def load_layout
    @layout = @site.layouts.find(params[:id])
  rescue ActiveRecord::RecordNotFound
    flash[:error] = 'Layout not found'
    redirect_to :action => :index
  end

end
