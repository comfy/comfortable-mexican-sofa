class CmsAdmin::SitesController < CmsAdmin::BaseController
  
  before_filter :load_site, :only => [:edit, :update, :destroy]
  
  def index
    
  end
  
  def new
    
  end
  
  def edit
    
  end
  
  def create
    
  end
  
  def update
    
  end
  
  def destroy
    
  end
  
protected
  
  def load_site
    @cms_site = CmsSite.find(params[:id])
  rescue ActiveRecord::RecordInvalid
    flash[:error] = 'Site not found'
    redirect_to :action => :index
  end
  
end