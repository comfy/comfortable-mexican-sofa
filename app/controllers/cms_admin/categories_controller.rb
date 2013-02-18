class CmsAdmin::CategoriesController < CmsAdmin::BaseController

  before_filter :load_category,
    :only => [:edit, :update, :destroy]

  helper_method :categorized_types, :collected_type

  def index
    @categories = @site.categories.unscoped.of_type(collected_type_formatted).order("position ASC")
  end

  def new
    @category = Cms::Category.new
  end

  def edit
  end

  def create
    begin
      @category = @site.categories.new(params[:category].merge(:categorized_type => collected_type_formatted))
      @category.save!
      if params[:from_crud].present?
        flash[:notice] = I18n.t('cms.categories.created')
        redirect_to cms_admin_site_categories_path(:type => collected_type)
      end
    rescue ActiveRecord::RecordInvalid
      logger.detailed_error($!)
      if params[:from_crud].present?
        flash.now[:error] = I18n.t('cms.categories.creation_failure')
        @category = Cms::Category.new
        render :action => :new
      else
        render :nothing => true
      end
    end
  end

  def update
    begin
      @category.update_attributes!(params[:category])
      if params[:from_crud].present?
        flash[:notice] = I18n.t('cms.categories.updated')
        redirect_to cms_admin_site_categories_path(:type => collected_type)
      end
    rescue ActiveRecord::RecordInvalid
      logger.detailed_error($!)
       if params[:from_crud].present?
        flash.now[:error] = I18n.t('cms.categories.update_failure')
        render :action => :edit
      else
        render :nothing => true
      end
    end
  end

  def destroy
    @category.destroy
    if params[:from_crud].present?
      flash[:notice] = I18n.t('cms.categories.deleted')
      redirect_to cms_admin_site_categories_path(:type => collected_type)
    end
  end

  def reorder

    Cms::Category.find(params[:id]).insert_at(params[:position].to_i) if params[:position]
    render :nothing => true
  rescue ActiveRecord::RecordNotFound
    render :nothing => true
  end

protected

  def collected_type
    if action_name == "index"
      current_type = params.fetch(:type, categorized_types.first)
      session[:current_type] = current_type
    end
    session[:current_type] || categorized_types.first
  end

  def collected_type_formatted
    "Cms::#{collected_type.capitalize}"
  end

  def categorized_types
    ["page", "file", "snippet"]
  end

  def load_category
    @category = @site.categories.find(params[:id])
  rescue ActiveRecord::RecordNotFound
    render :nothing => true
  end

end