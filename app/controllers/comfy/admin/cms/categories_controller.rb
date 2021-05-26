class Comfy::Admin::Cms::CategoriesController < Comfy::Admin::Cms::BaseController

  before_action :load_category,  :only => [:edit, :update, :destroy]
  before_action :authorize
  before_action :categories, only: [:create, :update]

  def edit
    render
  end

  def create
    @category = @site.categories.create!(category_params)
  rescue ActiveRecord::RecordInvalid
    head :ok
  end

  def update
    @category.update!(category_params)
  rescue ActiveRecord::RecordInvalid
    head :ok
  end

  def destroy
    @category.destroy
  end

protected

  def load_category
    @category = @site.categories.find(params[:id])
  rescue ActiveRecord::RecordNotFound
    head :ok
  end

  def category_params
    params.fetch(:category, {}).permit!
  end

  def categories
    @categories = params[:category]
  end
end