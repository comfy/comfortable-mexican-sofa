class CmsAdmin::CategoriesController < CmsAdmin::BaseController
  
  before_filter :load_category,  :only => [:edit, :update, :destroy]
  
  def edit
    render
  end
  
  def create
    @category = Cms::Category.create!(params[:category])
  rescue
    render :nothing => true
  end
  
  def update
    @category.update_attributes!(params[:category])
  rescue
    render :nothing => true
  end
  
  def destroy
    @category.destroy
  end
  
protected
  
  def load_category
    @category = Cms::Category.find(params[:id])
  rescue ActiveRecord::RecordNotFound
    render :nothing => true
  end
  
end