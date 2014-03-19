class Admin::Cms::PagesController < Admin::Cms::BaseController
  include ComfortableMexicanSofa::ViewMethods
  before_action :check_for_layouts, :only => [:new, :edit]
  before_action :build_cms_page,    :only => [:new, :create]
  before_action :load_cms_page,     :only => [:edit, :update, :destroy, :edit_block]
  before_action :preview_cms_page,  :only => [:create, :update]
  before_action :build_file,        :only => [:new, :edit]

  def index
    return redirect_to :action => :new if @site.pages.count == 0
    @pages_by_parent = @site.pages.includes(:categories).group_by(&:parent_id)
    if params[:category].present?
      @pages = @site.pages.includes(:categories).for_category(params[:category]).order('label')
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
    flash[:success] = I18n.t('cms.pages.created')
    redirect_to :action => :edit, :id => @page
  rescue ActiveRecord::RecordInvalid
    logger.detailed_error($!)
    flash.now[:error] = I18n.t('cms.pages.creation_failure')
    render :action => :new
  end

  def update
    @page.save!
    flash[:success] = I18n.t('cms.pages.updated')
    redirect_to :action => :edit, :id => @page
  rescue ActiveRecord::RecordInvalid
    logger.detailed_error($!)
    flash.now[:error] = I18n.t('cms.pages.update_failure')
    render :action => :edit
  end

  def destroy
    @page.destroy
    flash[:success] = I18n.t('cms.pages.deleted')
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
    (params[:cms_page] || []).each_with_index do |id, index|
      ::Cms::Page.where(:id => id).update_all(:position => index)
    end
    render :nothing => true
  end

  def duplicate
    original_page = @site.pages.find(params[:id])
    @page = original_page.dup
    @page.is_published = false
    @page.include_in_nav = false

    i = 0
    while @page.invalid?
      i += 1
      @page.slug = "#{original_page.slug}-#{i}"
    end

    @page.save!
    @page.blocks.delete_all

    original_page.blocks.each do |block|
      attributes = block.dup.attributes.except("page_id")
      @page.blocks.create(attributes)
    end

    redirect_to edit_admin_cms_site_page_path(@site, @page)
  end

  def edit_block
    @block = @page.blocks.find(params[:block_id])
    render :edit_block, layout: false
  end
  
  def update_block
    # TODO refactor this into the load_cms_page filter
    begin
      page = @site.pages.find(params[:id])
    rescue ActiveRecord::RecordNotFound
      render json: { error: "Cannot edit page #{params[:id]}" }
      return
    end
    
    block_params = update_block_params

    block = page.blocks.where(:id => block_params[:id]).first

    unless block && block.update(block_params) && page.save
      render json: { error: "Cannot edit page #{page.label}, please try again later" }, status: 422
      return
    end

    render json: { content: cms_page_block_content(block.identifier.to_sym, page), block_id: block.id }
  end

protected

  def check_for_layouts
    if @site.layouts.count == 0
      flash[:error] = I18n.t('cms.pages.layout_not_found')
      redirect_to new_admin_cms_site_layout_path(@site)
    end
  end

  def build_cms_page
    @page = @site.pages.new(page_params)
    @page.parent ||= (@site.pages.find_by_id(params[:parent_id]) || @site.pages.root)
    @page.layout ||= (@page.parent && @page.parent.layout || @site.layouts.first)
  end

  def build_file
    @file = Cms::File.new
  end

  def load_cms_page
    @page = @site.pages.find(params[:id])
    @page.attributes = page_params
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
      render :inline => @page.render, :layout => layout, :content_type => 'text/html'
    end
  end
  
  def page_params
    params.fetch(:page, {}).permit!
  end


  def update_block_params
    params.require(:block).permit(:id, :content)
  end
end
