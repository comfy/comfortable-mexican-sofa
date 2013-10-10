class Admin::Cms::SitesController < Admin::Cms::BaseController

  skip_before_action  :load_admin_site,
                      :load_fixtures

  before_action :build_site,  :only => [:new, :create]
  before_action :load_site,   :only => [:edit, :update, :destroy]

  def index
    return redirect_to :action => :new if ::Cms::Site.count == 0
    @site = ::Cms::Site.find_by_id(session[:site_id])
    @sites ||= ::Cms::Site.all
  end

  def new
    render
  end

  def edit
    render
  end

  def create
    @site.save!
    flash[:success] = I18n.t('cms.sites.created')
    redirect_to admin_cms_site_layouts_path(@site)
  rescue ActiveRecord::RecordInvalid
    logger.detailed_error($!)
    flash.now[:error] = I18n.t('cms.sites.creation_failure')
    render :action => :new
  end

  def update
    @site.update_attributes!(site_params)
    flash[:success] = I18n.t('cms.sites.updated')
    redirect_to :action => :edit, :id => @site
  rescue ActiveRecord::RecordInvalid
    logger.detailed_error($!)
    flash.now[:error] = I18n.t('cms.sites.update_failure')
    render :action => :edit
  end

  def destroy
    @site.destroy
    flash[:success] = I18n.t('cms.sites.deleted')
    redirect_to :action => :index
  end

protected

  def build_site
    @site = ::Cms::Site.new(site_params)
    @site.hostname ||= request.host.downcase
  end

  def load_site
    @site = ::Cms::Site.find(params[:id])
    I18n.locale = ComfortableMexicanSofa.config.admin_locale || @site.locale
  rescue ActiveRecord::RecordNotFound
    flash[:error] = I18n.t('cms.sites.not_found')
    redirect_to :action => :index
  end
  
  def site_params
    params.fetch(:site, {}).permit!
  end

end
