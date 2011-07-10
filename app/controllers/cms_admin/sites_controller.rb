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
    flash[:notice] = I18n.t('cms.sites.created')
    redirect_to cms_admin_site_layouts_path(@site)
  rescue ActiveRecord::RecordInvalid
    flash.now[:error] = I18n.t('cms.sites.creation_failure')
    render :action => :new
  end

  def update
    @site.update_attributes!(params[:site])
    flash[:notice] = I18n.t('cms.sites.updated')
    redirect_to :action => :edit, :id => @site
  rescue ActiveRecord::RecordInvalid
    flash.now[:error] = I18n.t('cms.sites.update_failure')
    render :action => :edit
  end

  def destroy
    @site.destroy
    flash[:notice] = I18n.t('cms.sites.deleted')
    redirect_to :action => :index
  end

protected

  def build_site
    @site = Cms::Site.new(params[:site])
    @site.hostname ||= request.host.downcase
  end

  def load_site
    @site = Cms::Site.find(params[:id])
    I18n.locale = ComfortableMexicanSofa.config.admin_locale || @site.locale
  rescue ActiveRecord::RecordNotFound
    flash[:error] = I18n.t('cms.sites.not_found')
    redirect_to :action => :index
  end

end