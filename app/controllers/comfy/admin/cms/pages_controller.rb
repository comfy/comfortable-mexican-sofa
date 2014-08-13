class Comfy::Admin::Cms::PagesController < Comfy::Admin::Cms::BaseController

  before_action :check_for_layouts, :only => [:new, :edit]
  before_action :build_cms_page,    :only => [:new, :create]
  before_action :load_cms_page,     :only => [:edit, :update, :destroy]
  before_action :preview_cms_page,  :only => [:create, :update]
  before_action :build_file,        :only => [:new, :edit]

  def index
    @pages = @site.pages

    return redirect_to :action => :new if @pages.count == 0
    @pages_by_parent = @pages.includes(:categories).group_by(&:parent_id)

    @filters_present = params[:category].present? || params[:search].present?

    @pages = @pages.includes(:categories).for_category(params[:category]).order('label') if params[:category].present?
    @pages = Comfy::Cms::Search.new(@pages, params[:search]).results if params[:search].present?

    @pages = [@pages.root].compact unless @filters_present
  end

  def new
    render
  end

  def edit
    @categories = Comfy::Cms::CategoriesListPresenter.new(@site.categories.of_type(@page.class.to_s))
    render
  end

  def create
    @page.save!
    flash[:success] = I18n.t('comfy.admin.cms.pages.created')
    redirect_to :action => :edit, :id => @page
  rescue ActiveRecord::RecordInvalid
    flash.now[:danger] = I18n.t('comfy.admin.cms.pages.creation_failure')
    render :action => :new
  end

  def update
    @page.save!
    flash[:success] = I18n.t('comfy.admin.cms.pages.updated')
    redirect_to :action => :edit, :id => @page
  rescue ActiveRecord::RecordInvalid
    flash.now[:danger] = I18n.t('comfy.admin.cms.pages.update_failure')
    render :action => :edit
  end

  def destroy
    @page.destroy
    flash[:success] = I18n.t('comfy.admin.cms.pages.deleted')
    redirect_to :action => :index
  end

  def form_blocks
    @page = @site.pages.find_by_id(params[:id]) || @site.pages.new
    @page.layout = @site.layouts.find_by_id(params[:layout_id])
  end

  def toggle_branch
    @pages_by_parent = @site.pages.includes(:categories).group_by(&:parent_id)
    @page = @site.pages.find(params[:id])
    s   = (session[:cms_page_tree] ||= [])
    id  = @page.id.to_s
    s.member?(id) ? s.delete(id) : s << id
  rescue ActiveRecord::RecordNotFound
    # do nothing
  end

  def reorder
    (params[:comfy_cms_page] || []).each_with_index do |id, index|
      ::Comfy::Cms::Page.where(:id => id).update_all(:position => index)
    end
    render :nothing => true
  end

protected

  def check_for_layouts
    if @site.layouts.count == 0
      flash[:danger] = I18n.t('comfy.admin.cms.pages.layout_not_found')
      redirect_to new_comfy_admin_cms_site_layout_path(@site)
    end
  end

  def build_cms_page
    @page = @site.pages.new(page_params)
    @page.parent ||= (@site.pages.find_by_id(params[:parent_id]) || @site.pages.root)
    @page.layout ||= (@page.parent && @page.parent.layout || @site.layouts.first)
  end

  def build_file
    @file = Comfy::Cms::File.new
  end

  def load_cms_page
    @page = @site.pages.find(params[:id])
    @page.attributes = page_params
    @page.layout ||= (@page.parent && @page.parent.layout || @site.layouts.first)
  rescue ActiveRecord::RecordNotFound
    flash[:danger] = I18n.t('comfy.admin.cms.pages.not_found')
    redirect_to :action => :index
  end

  def preview_cms_page
    if params[:preview]
      layout = @page.layout.app_layout.blank?? false : @page.layout.app_layout
      @cms_site   = @page.site
      @cms_layout = @page.layout
      @cms_page   = @page

      # Chrome chokes on content with iframes. Issue #434
      response.headers['X-XSS-Protection'] = '0'

      render :inline => @page.render, :layout => layout, :content_type => 'text/html'
    end
  end

  def page_params
    params.fetch(:page, {}).permit!
  end
end
