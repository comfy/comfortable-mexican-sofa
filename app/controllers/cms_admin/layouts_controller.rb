class CmsAdmin::LayoutsController < CmsAdmin::BaseController
  
  before_filter :build_cms_layout,  :only => [:new, :create]
  before_filter :load_cms_layout,   :only => [:edit, :update, :destroy]
  
  def index
    @cms_layouts = CmsLayout
  end
  
  def new
    render
  end
  
  def edit
    render
  end
  
  def create
    @cms_layout.save!
    flash[:notice] = 'Layout successfully created'
    redirect_to :action => :edit, :id => @cms_layout
  rescue ActiveRecord::RecordInvalid
    render :action => :new
  end
  
  def update
    @cms_layout.update_attributes!(params[:cms_layout])
    flash[:notice] = 'Layout successfully updated'
    redirect_to :action => :edit, :id => @cms_layout
  rescue ActiveRecord::RecordInvalid
    render :action => :edit
  end
  
  def destroy
    @cms_layout.destroy
    flash[:notice] = 'Layout deleted'
    redirect_to :action => :index
  end
  
protected
  
  def build_cms_layout
    @cms_layout = CmsLayout.new(params[:cms_layout])
  end
  
  def load_cms_layout
    @cms_layout = CmsLayout.find(params[:id])
  rescue ActiveRecord::RecordNotFound
    flash[:error] = 'Layout not found'
    redirect_to :action => :index
  end
  
end
