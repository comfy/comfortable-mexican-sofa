class CmsAdmin::LayoutsController < CmsAdmin::BaseController
  before_filter :load_layout, :only => [:toggle, :edit, :update, :destroy]
  before_filter :build_layout, :only => [ :new, :create ]
  
  def index
    @cms_layouts = CmsLayout.roots
  end
  
  def toggle
    save_tree_state(@cms_layout)
    render :nothing => true
  end
  
  def new
  end
  
  def create
    @cms_layout.save!
    
    flash[:notice] = 'Layout created'
    redirect_to edit_cms_admin_layout_path(@cms_layout)    
  rescue ActiveRecord::RecordInvalid
    render :action => :new
  end
  
  def edit
    # ...
  end
  
  def update
    @cms_layout.update_attributes!(params[:cms_layout])
    
    flash[:notice] = 'Layout updated'
    redirect_to edit_cms_admin_layout_path(@cms_layout)
    
  rescue ActiveRecord::RecordInvalid
    render :action => :edit
  end
  
  def destroy
    @cms_layout.destroy
    
    flash[:notice] = 'Layout removed'
    redirect_to cms_admin_layouts_path
  end
  
  def reorder
    params[:cms_layout].each_with_index do |id, index|
      CmsLayout.update_all(['position = %d', index], ['id = %d', id])
    end

    render :nothing => true
  end
  
protected
  def build_layout
    params[:cms_layout] ||= {
      :parent_id => params[:parent_id],
      :content => '{{cms_page_block:default:text}}'
    }
    
    @cms_layout = CmsLayout.new(params[:cms_layout])
  end

  def load_layout
    @cms_layout = CmsLayout.find_by_id(params[:id])
  end
end
