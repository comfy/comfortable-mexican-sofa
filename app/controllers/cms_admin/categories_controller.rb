class CmsAdmin::CategoriesController < CmsAdmin::BaseController

  before_filter :load_category,
    :only => [:edit, :update, :destroy]

  helper_method :categorized_types, :collected_type,
    :collected_type_formatted

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
      @category = @site.categories.new(params[:category])
      @category.save!
      unless request.xhr?
        flash[:notice] = I18n.t('cms.categories.created')
        redirect_to cms_admin_site_categories_path(:type => collected_type)
      end
    rescue ActiveRecord::RecordInvalid
      logger.detailed_error($!)
      unless request.xhr?
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
      unless request.xhr?
        flash[:notice] = I18n.t('cms.categories.updated')
        redirect_to cms_admin_site_categories_path(:type => collected_type)
      end
    rescue ActiveRecord::RecordInvalid
      logger.detailed_error($!)
       unless request.xhr?
        flash.now[:error] = I18n.t('cms.categories.update_failure')
        render :action => :edit
      else
        render :nothing => true
      end
    end
  end

  def destroy
    @category.destroy
    unless request.xhr?
      flash[:notice] = I18n.t('cms.categories.deleted')
      redirect_to cms_admin_site_categories_path(:type => collected_type)
    end
  end

  # reorder method is used to reorder the categories in their list
  # The lists are organized by categorizated_type and site ID.
  # params: +position+ the position to be take by the category
  # +id+ the ID of category to be reorder.
  def reorder
    unless params[:position].blank?
      Cms::Category.find(params[:id].to_i).insert_at(params[:position].to_i)
    end
    render :nothing => true
  rescue ActiveRecord::RecordNotFound
    render :nothing => true
  end

protected

  # Collected Type is used just in the CRUD actions of Categories Controller
  # it returns the categorization type existent in the params, otherwise pick
  # the default categorization type of white list bellow
  def collected_type
    current_type = params.fetch(:type, categorized_types.first)
    return current_type if categorized_types.include?(current_type)
  end

  # collected_type_formatted formats the collected type
  # with the Ruby namespace syntax
  def collected_type_formatted(type = nil)
    type ||= collected_type
    "Cms::#{type.capitalize}"
  end

  # The white list of all the Categorized Types avaliable
  def categorized_types
    ["page", "file", "snippet"]
  end

  def load_category
    @category = @site.categories.find(params[:id])
  rescue ActiveRecord::RecordNotFound
    render :nothing => true
  end

end