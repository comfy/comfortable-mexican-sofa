class CmsAdmin::CategoriesController < CmsAdmin::BaseController
  before_filter :load_category, :except => [:create, :new, :index]
  
  def index
    @cms_categories = CmsCategory.roots
  end
  
=begin
  This was the old style of getting the children of the current note (old cms stuff)
  def children
    manage_session_array(:cms_category_tree, (params[:state] == 'open' ? :remove : :add), params[:id])
  end
=end
  
  def new
    @cms_category = CmsCategory.new(params.slice(:parent_id))
  end

  def toggle
    save_tree_state(@cms_category)
    render :nothing => true
  end
  
  def create
    @cms_category = CmsCategory.new(params[:cms_category])
    @cms_category.save!
    
    flash[:notice] = 'Category created'
    respond_to do |format|
      format.html { redirect_to edit_cms_admin_category_path(@cms_category) }
      format.js
    end
  
  rescue ActiveRecord::RecordInvalid
    respond_to do |format|
      format.html { render :action => 'new' }
      format.js
    end
  end
  
  def edit
    # ...
  end

  def update
    @cms_category.update_attributes!(params[:cms_category])
    flash[:notice] = 'Category updated'
    respond_to do |format|
      format.html { redirect_to edit_cms_admin_category_path(@cms_category)}
      format.js
    end
  
  rescue ActiveRecord::RecordInvalid
    respond_to do |format|
      format.html { render :action => 'edit' }
      format.js
    end
  end
  
  def show
    
  end
  
  def destroy
    @cms_category.destroy
    flash[:notice] = 'Category deleted'
    redirect_to cms_admin_categories_path
  end

protected
  
  def load_category
    @cms_category = CmsCategory.find(params[:id])
  rescue ActiveRecord::RecordNotFound
    render :text => 'Item not found', :status => 404
  end
  
end
