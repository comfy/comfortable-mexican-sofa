class CmsAdmin::PagesController < CmsAdmin::BaseController
  
  include CmsCommon::RenderPage
  
  before_filter :load_page, :only => [:toggle, :edit, :update, :destroy, :reorder]
  before_filter :build_page, :only => [ :new, :create ]
  
  def index
    if (ComfortableMexicanSofa::Config.multiple_sites)
      @sites = CmsSite.all
      @cms_pages = CmsPage.roots.group_by(&:cms_site_id)
    else
      params[:root] ? @cms_pages = CmsPage.find(params[:root]).children : @cms_pages = CmsPage.roots
    end
  end
  
  def toggle
    save_tree_state(@cms_page)
    render :nothing => true
  end
  
  def new
    @cms_page.cms_layout = @cms_page.parent.cms_layout if @cms_page.parent
  end
  
  def edit
    # ...
  end
  
  def create
    return render_page if !params[:preview].blank? && @cms_page.valid?
    
    @cms_page.save!
    
    flash[:notice] = 'Page created'
    redirect_to edit_cms_admin_page_path(@cms_page)
    
  rescue ActiveRecord::RecordInvalid
    render :action => :new
  end
  
  def update
    @cms_page.attributes = params[:cms_page]
    
    return render_page if !params[:preview].blank? && @cms_page.valid?
    
    @cms_page.save!
    
    flash[:notice] = 'Page updated'
    redirect_to edit_cms_admin_page_path(@cms_page)
    
  rescue ActiveRecord::RecordInvalid
    render :action => :edit
  end
  
  def destroy
    @cms_page.destroy
    
    flash[:notice] = 'Page removed'
    redirect_to cms_admin_pages_path
  end
  
  def form_blocks
    @cms_page = CmsPage.find_by_id(params[:id])
    @layout = CmsLayout.find(params[:layout_id])
  end
  
  def reorder
    params[:cms_page].each_with_index do |id, index|
      CmsPage.update_all(['position = %d', index], ['id = %d', id])
    end
    render :nothing => true
  end
  
protected
  def load_page
    @cms_page = CmsPage.find_by_id(params[:id])
  end
  
  def build_page
    @parent_page = (params[:parent_id] and CmsPage.find_by_id(params[:parent_id]))
    
    @cms_page = CmsPage.new(params[:cms_page])

    if (@cms_page.parent ||= @parent_page)
      @cms_page.cms_site = @cms_page.parent.cms_site
    end
  end
end
