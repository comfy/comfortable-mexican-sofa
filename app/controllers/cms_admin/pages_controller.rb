class CmsAdmin::PagesController < CmsAdmin::BaseController

  before_filter :check_for_layouts, :only => [:new, :edit]
  before_filter :build_cms_page,    :only => [:new, :create]
  before_filter :load_cms_page,     :only => [:edit, :update, :destroy]
  before_filter :preview_cms_page,  :only => [:create, :update]
  before_filter :build_file,        :only => [:new, :edit]

  def index
    return redirect_to :action => :new if @site.pages.count == 0
    if params[:category].present?
      @pages = @site.pages.includes(:categories).for_category(params[:category]).all(:order => 'label')
    else
      @pages = [@site.pages.root].compact
    end
  end

  def new
    render
  end

  def edit
    render
  end

  def create
    @page.save!
    flash[:notice] = I18n.t('cms.pages.created')
    redirect_to :action => :edit, :id => @page
  rescue ActiveRecord::RecordInvalid
    logger.detailed_error($!)
    flash.now[:error] = I18n.t('cms.pages.creation_failure')
    render :action => :new
  end

  def update
    @page.save!
    flash[:notice] = I18n.t('cms.pages.updated')
    redirect_to :action => :edit, :id => @page
  rescue ActiveRecord::RecordInvalid
    logger.detailed_error($!)
    flash.now[:error] = I18n.t('cms.pages.update_failure')
    render :action => :edit
  end

  def destroy
    @page.destroy
    flash[:notice] = I18n.t('cms.pages.deleted')
    redirect_to :action => :index
  end

  def form_blocks
    @page = @site.pages.find_by_id(params[:id]) || @site.pages.new
    @page.layout = @site.layouts.find_by_id(params[:layout_id])
  end

  def toggle_branch
    @page = @site.pages.find(params[:id])
    s   = (session[:cms_page_tree] ||= [])
    id  = @page.id.to_s
    s.member?(id) ? s.delete(id) : s << id
  rescue ActiveRecord::RecordNotFound
    # do nothing
  end

  def reorder
    (params[:cms_page] || []).each_with_index do |id, index|
      Cms::Page.where(:id => id).update_all(:position => index)
    end
    render :nothing => true
  end

protected

  def check_for_layouts
    if @site.layouts.count == 0
      flash[:error] = I18n.t('cms.pages.layout_not_found')
      redirect_to new_cms_admin_site_layout_path(@site)
    end
  end

  def build_cms_page
    @page = @site.pages.new(params[:page])
    @page.parent ||= (@site.pages.find_by_id(params[:parent_id]) || @site.pages.root)
    @page.layout ||= (@page.parent && @page.parent.layout || @site.layouts.first)
  end

  def build_file
    @file = Cms::File.new
  end

  def load_cms_page
    @page = @site.pages.find(params[:id])
    @page.attributes = params[:page]
    @page.layout ||= (@page.parent && @page.parent.layout || @site.layouts.first)
  rescue ActiveRecord::RecordNotFound
    flash[:error] = I18n.t('cms.pages.not_found')
    redirect_to :action => :index
  end

  def preview_cms_page
    if params[:preview]
      layout = @page.layout.app_layout.blank?? false : @page.layout.app_layout
      @cms_site   = @page.site
      @cms_layout = @page.layout
      @cms_page   = @page
      render :inline => @page.content(true), :layout => layout
    end
  end
end
