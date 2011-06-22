class CmsAdmin::SitesController < CmsAdmin::BaseController

  skip_before_filter  :load_admin_site,
                      :load_fixtures

  before_filter :build_site,  :only => [:new, :create]
  before_filter :load_site,   :only => [:edit, :update, :destroy]

  def index
    return redirect_to :action => :new if Cms::Site.count == 0
    @sites = Cms::Site.all
  end

  def new
    render
  end

  def edit
    render
  end

  def create
    @site.save!
    flash[:notice] = 'Site created'
    redirect_to :action => :edit, :id => @site
  rescue ActiveRecord::RecordInvalid
    flash.now[:error] = 'Failed to create site'
    render :action => :new
  end

  def update
    @site.update_attributes!(params[:site])
    flash[:notice] = 'Site updated'
    redirect_to :action => :edit, :id => @site
  rescue ActiveRecord::RecordInvalid
    flash.now[:error] = 'Failed to update site'
    render :action => :edit
  end

  def destroy
    @site.destroy
    flash[:notice] = 'Site deleted'
    redirect_to :action => :index
  end

protected

  def build_site
    @site = Cms::Site.new(params[:site])
    @site.hostname ||= request.host.downcase
  end

  def load_site
    @site = Cms::Site.find(params[:id])
  rescue ActiveRecord::RecordNotFound
    flash[:error] = 'Site not found'
    redirect_to :action => :index
  end

end