class Comfy::Admin::Cms::LayoutsController < Comfy::Admin::Cms::BaseController

  prepend_before_action :build_layout,  :only => [:new, :create]
  prepend_before_action :load_layout,   :only => [:edit, :update, :destroy]

  def index
    return redirect_to :action => :new if current_site.layouts.count == 0
    @layouts = current_site.layouts.roots
  end

  def new
    render
  end

  def edit
    render
  end

  def create
    @layout.save!
    flash[:success] = I18n.t('comfy.admin.cms.layouts.created')
    redirect_to :action => :edit, :id => @layout
  rescue ActiveRecord::RecordInvalid
    flash.now[:danger] = I18n.t('comfy.admin.cms.layouts.creation_failure')
    render :action => :new
  end

  def update
    @layout.update_attributes!(layout_params)
    flash[:success] = I18n.t('comfy.admin.cms.layouts.updated')
    redirect_to :action => :edit, :id => @layout
  rescue ActiveRecord::RecordInvalid
    flash.now[:danger] = I18n.t('comfy.admin.cms.layouts.update_failure')
    render :action => :edit
  end

  def destroy
    @layout.destroy
    flash[:success] = I18n.t('comfy.admin.cms.layouts.deleted')
    redirect_to :action => :index
  end
  
  def reorder
    (params[:comfy_cms_layout] || []).each_with_index do |id, index|
      ::Comfy::Cms::Layout.where(:id => id).update_all(:position => index)
    end
    render :nothing => true
  end

protected

  def build_layout
    @layout = current_site.layouts.new(layout_params)
    @layout.parent      ||= ::Comfy::Cms::Layout.find_by_id(params[:parent_id])
    @layout.app_layout  ||= @layout.parent.try(:app_layout)
    @layout.content     ||= '{{ cms:page:content:rich_text }}'
  end

  def load_layout
    @layout = current_site.layouts.find(params[:id])
  rescue ActiveRecord::RecordNotFound
    flash[:danger] = I18n.t('comfy.admin.cms.layouts.not_found')
    redirect_to :action => :index
  end
  
  def layout_params
    params.fetch(:layout, {}).permit!
  end
  
end
