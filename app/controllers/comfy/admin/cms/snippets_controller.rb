# frozen_string_literal: true

class Comfy::Admin::Cms::SnippetsController < Comfy::Admin::Cms::BaseController
  include ::Comfy::ReorderAction
  self.reorder_action_resource = ::Comfy::Cms::Snippet

  before_action :build_snippet, only: %i[new create]
  before_action :load_snippet,  only: %i[edit update destroy]
  before_action :authorize

  def index
    return redirect_to action: :new if @site.snippets.count.zero?

    @snippets = @site.snippets.includes(:categories).for_category(params[:categories]).order(:position)
  end

  def new
    render
  end

  def edit
    @snippet.attributes = snippet_params
  end

  def create
    @snippet.save!
    flash[:success] = I18n.t('comfy.admin.cms.snippets.created')
    redirect_to action: :edit, id: @snippet
  rescue ActiveRecord::RecordInvalid
    flash.now[:danger] = I18n.t('comfy.admin.cms.snippets.creation_failure')
    render action: :new
  end

  def update
    @snippet.update!(snippet_params)
    flash[:success] = I18n.t('comfy.admin.cms.snippets.updated')
    redirect_to action: :edit, id: @snippet
  rescue ActiveRecord::RecordInvalid
    flash.now[:danger] = I18n.t('comfy.admin.cms.snippets.update_failure')
    render action: :edit
  end

  def destroy
    @snippet.destroy
    flash[:success] = I18n.t('comfy.admin.cms.snippets.deleted')
    redirect_to action: :index
  end

protected

  def build_snippet
    @snippet = @site.snippets.new(snippet_params)
  end

  def load_snippet
    @snippet = @site.snippets.find(params[:id])
  rescue ActiveRecord::RecordNotFound
    flash[:danger] = I18n.t('comfy.admin.cms.snippets.not_found')
    redirect_to action: :index
  end

  def snippet_params
    params.fetch(:snippet, {}).permit!
  end
end
