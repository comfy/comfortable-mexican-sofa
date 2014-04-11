class Admin::Cms::SitesController < Admin::Cms::BaseController
  load_and_authorize_resource :site, class: "Cms::Site", parent: false

  skip_before_action  :load_admin_site,
                      :load_fixtures

  before_action :set_hostname,  :only => [:new, :create]
  before_action :set_locale,   :only => [:edit, :update, :destroy]

  def index
    respond_to do |format|
      format.html do
        return redirect_to :action => :new if ::Cms::Site.count == 0
        @site = ::Cms::Site.find_by_id(session[:site_id])
        @sites ||= ::Cms::Site.all
      end
      # I'm reluctant to remove root objects globally.
      format.json do
        # Use AREL so we'll benefit from ilike with Postgres.
        sites = Cms::Site.arel_table
        result = @sites.where(sites[:label].matches("%#{params[:q]}%"))
        render json: result.map(&:attributes)
      end
    end
  end

  def new
    render
  end

  def edit
    render
  end

  def create
    @site.users << current_admin_cms_user unless current_admin_cms_user.super_admin?
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

  def set_hostname
    @site.hostname ||= request.host.downcase
  end

  def set_locale
    I18n.locale = ComfortableMexicanSofa.config.admin_locale || @site.locale
  end
  
  def site_params
    params.fetch(:site, {}).permit!
  end

end
