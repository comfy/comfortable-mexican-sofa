class Admin::Cms::SnippetsController < Admin::Cms::BaseController

  before_action :build_snippet, :only => [:new, :create]
  before_action :load_snippet,  :only => [:edit, :update, :destroy]

  def index
    return redirect_to :action => :new if @site.snippets.count == 0
    @snippets = @site.snippets.includes(:categories).for_category(params[:category])
  end

  def new
    render
  end

  def edit
    @snippet.attributes = snippet_params
  end

  def create
    @snippet.save!
    flash[:success] = I18n.t('cms.snippets.created')
    redirect_to :action => :edit, :id => @snippet
  rescue ActiveRecord::RecordInvalid
    logger.detailed_error($!)
    flash.now[:error] = I18n.t('cms.snippets.creation_failure')
    render :action => :new
  end

  def update
    @snippet.update_attributes!(snippet_params)
    flash[:success] = I18n.t('cms.snippets.updated')
    redirect_to :action => :edit, :id => @snippet
  rescue ActiveRecord::RecordInvalid
    logger.detailed_error($!)
    flash.now[:error] = I18n.t('cms.snippets.update_failure')
    render :action => :edit
  end

  def destroy
    @snippet.destroy
    flash[:success] = I18n.t('cms.snippets.deleted')
    redirect_to :action => :index
  end
  
  def reorder
    (params[:cms_snippet] || []).each_with_index do |id, index|
      ::Cms::Snippet.where(:id => id).update_all(:position => index)
    end
    render :nothing => true
  end

protected

  def build_snippet
    @snippet = @site.snippets.new(snippet_params)
  end

  def load_snippet
    @snippet = @site.snippets.find(params[:id])
  rescue ActiveRecord::RecordNotFound
    flash[:error] = I18n.t('cms.snippets.not_found')
    redirect_to :action => :index
  end
  
  def snippet_params
    params.fetch(:snippet, {}).permit!
  end
end
