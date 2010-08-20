class CmsAdmin::SitesController < CmsAdmin::BaseController
  before_filter :load_site, :only => [ :edit, :update, :destroy ]
  before_filter :build_site, :only => [ :new, :create ]
  
  def index
    @sites = CmsSite.all
  end
  
  def children
    manage_session_array(:cms_site_tree, (params[:state] == 'open' ? :remove : :add), params[:id])
  end
  
  def new
    if (CmsSite.count == 0)
      @site.hostname = request.host
    end
  end
  
  def edit
    # ...
  end
  
  def create
    @site.save!
    
    flash[:notice] = 'Site created'

    redirect_to edit_cms_admin_site_path(@site)
    
  rescue ActiveRecord::RecordInvalid
    render(:action => :new)
  end
  
  def update
    @site.update_attributes!(params[:cms_site])
    
    flash[:notice] = 'Site updated'

    redirect_to edit_cms_admin_site_path(@site)
    
  rescue ActiveRecord::RecordInvalid
    render :action => :edit
  end
  
  def destroy
    @site.destroy
    
    flash[:notice] = 'Site removed'
    redirect_to cms_admin_sites_path
  end
  
protected
  def load_site
    @site = CmsSite.find_by_id(params[:id])
  end
  
  def build_site
    params[:cms_site] ||= {
    }

    @site = CmsSite.new(params[:cms_site])
  end
end
