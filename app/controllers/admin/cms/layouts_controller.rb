class Admin::Cms::LayoutsController < Admin::Cms::BaseController

  before_action :build_layout,  :only => [:new, :create]
  before_action :load_layout,   :only => [:edit, :update, :destroy]

  def index
    return redirect_to :action => :new if @site.layouts.count == 0
    @layouts = @site.layouts.roots
  end

  def new
    render
  end

  def edit
    render
  end

  def create
    @layout.save!
    flash[:success] = I18n.t('cms.layouts.created')
    redirect_to :action => :edit, :id => @layout
  rescue ActiveRecord::RecordInvalid
    logger.detailed_error($!)
    flash.now[:error] = I18n.t('cms.layouts.creation_failure')
    render :action => :new
  end

  def update
    @layout.update_attributes!(layout_params)
    flash[:success] = I18n.t('cms.layouts.updated')
    redirect_to :action => :edit, :id => @layout
  rescue ActiveRecord::RecordInvalid
    logger.detailed_error($!)
    flash.now[:error] = I18n.t('cms.layouts.update_failure')
    render :action => :edit
  end

  def destroy
    @layout.destroy
    flash[:success] = I18n.t('cms.layouts.deleted')
    redirect_to :action => :index
  end
  
  def reorder
    (params[:cms_layout] || []).each_with_index do |id, index|
      ::Cms::Layout.where(:id => id).update_all(:position => index)
    end
    render :nothing => true
  end

protected

  def build_layout
    @layout = @site.layouts.new(layout_params)
    @layout.parent      ||= ::Cms::Layout.find_by_id(params[:parent_id])
    @layout.app_layout  ||= @layout.parent.try(:app_layout)
    @layout.content     ||= '{{ cms:page:content:text }}'
  end

  def load_layout
    @layout = @site.layouts.find(params[:id])
  rescue ActiveRecord::RecordNotFound
    flash[:error] = I18n.t('cms.layouts.not_found')
    redirect_to :action => :index
  end
  
  def layout_params
    params.fetch(:layout, {}).permit!
  end
  
end
