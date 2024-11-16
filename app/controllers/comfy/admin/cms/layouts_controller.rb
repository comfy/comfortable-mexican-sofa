# frozen_string_literal: true

class Comfy::Admin::Cms::LayoutsController < Comfy::Admin::Cms::BaseController
  include ::Comfy::ReorderAction
  self.reorder_action_resource = ::Comfy::Cms::Layout

  before_action :build_layout,  only: %i[new create]
  before_action :load_layout,   only: %i[edit update destroy]
  before_action :authorize

  def index
    return redirect_to action: :new if @site.layouts.count.zero?

    @layouts = @site.layouts.roots.order(:position)
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
    redirect_to action: :edit, id: @layout
  rescue ActiveRecord::RecordInvalid
    flash.now[:danger] = I18n.t('comfy.admin.cms.layouts.creation_failure')
    render action: :new
  end

  def update
    @layout.update!(layout_params)
    flash[:success] = I18n.t('comfy.admin.cms.layouts.updated')
    redirect_to action: :edit, id: @layout
  rescue ActiveRecord::RecordInvalid
    flash.now[:danger] = I18n.t('comfy.admin.cms.layouts.update_failure')
    render action: :edit
  end

  def destroy
    @layout.destroy
    flash[:success] = I18n.t('comfy.admin.cms.layouts.deleted')
    redirect_to action: :index
  end

protected

  def build_layout
    @layout = @site.layouts.new(layout_params)
    @layout.parent      ||= ::Comfy::Cms::Layout.find_by_id(params[:parent_id])
    @layout.app_layout  ||= @layout.parent.try(:app_layout)
    @layout.content     ||= '{{ cms:wysiwyg content }}'
  end

  def load_layout
    @layout = @site.layouts.find(params[:id])
  rescue ActiveRecord::RecordNotFound
    flash[:danger] = I18n.t('comfy.admin.cms.layouts.not_found')
    redirect_to action: :index
  end

  def layout_params
    params.fetch(:layout, {}).permit!
  end
end
