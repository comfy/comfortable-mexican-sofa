class CmsAdmin::SnippetsController < CmsAdmin::BaseController

  before_filter :build_snippet, :only => [:new, :create]
  before_filter :load_snippet,  :only => [:edit, :update, :destroy]

  def index
    return redirect_to :action => :new if @site.snippets.count == 0
    @snippets = @site.snippets.all(:order => 'label')
  end

  def new
    render
  end

  def edit
    render
  end

  def create
    @snippet.save!
    flash[:notice] = 'Snippet created'
    redirect_to :action => :edit, :id => @snippet
  rescue ActiveRecord::RecordInvalid
    flash.now[:error] = 'Failed to create snippet'
    render :action => :new
  end

  def update
    @snippet.update_attributes!(params[:snippet])
    flash[:notice] = 'Snippet updated'
    redirect_to :action => :edit, :id => @snippet
  rescue ActiveRecord::RecordInvalid
    flash.now[:error] = 'Failed to update snippet'
    render :action => :edit
  end

  def destroy
    @snippet.destroy
    flash[:notice] = 'Snippet deleted'
    redirect_to :action => :index
  end

protected

  def build_snippet
    @snippet = @site.snippets.new(params[:snippet])
  end

  def load_snippet
    @snippet = @site.snippets.find(params[:id])
  rescue ActiveRecord::RecordNotFound
    flash[:error] = 'Snippet not found'
    redirect_to :action => :index
  end
end
