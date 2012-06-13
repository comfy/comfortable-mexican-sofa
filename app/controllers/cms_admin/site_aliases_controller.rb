class CmsAdmin::SiteAliasesController < CmsAdmin::BaseController

  before_filter :build_site,  :only => [:new, :create]
  before_filter :load_site,   :only => [:edit, :update, :destroy]

  def new
    render
  end

  def edit
    render
  end

  def create
    @site_alias.save!
    flash[:notice] = I18n.t('cms.site_aliases.created')
    redirect_to cms_admin_sites_path()
  rescue ActiveRecord::RecordInvalid
    logger.detailed_error($!)
    flash.now[:error] = I18n.t('cms.site_aliases.creation_failure')
    render :action => :new
  end

  def update
    @site_alias.update_attributes!(params[:site_alias])
    flash[:notice] = I18n.t('cms.site_aliases.updated')
    redirect_to :action => :edit, :id => @site_alias
  rescue ActiveRecord::RecordInvalid
    logger.detailed_error($!)
    flash.now[:error] = I18n.t('cms.site_aliases.update_failure')
    render :action => :edit
  end

  def destroy
    @site_alias.destroy
    flash[:notice] = I18n.t('cms.site_aliases.deleted')
    redirect_to cms_admin_sites_path()
  end

protected

  def build_site
    @site_alias = @site.site_aliases.new(params[:site_alias])
  end

  def load_site
    @site_alias = @site.site_aliases.find(params[:id])
  rescue ActiveRecord::RecordNotFound
    flash[:error] = I18n.t('cms.site_aliases.not_found')
    redirect_to :action => :index
  end

end
