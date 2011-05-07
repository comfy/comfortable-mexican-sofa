class CmsAdmin::SnippetsController < CmsAdmin::BaseController

  before_filter :build_cms_snippet, :only => [:new, :create]
  before_filter :load_cms_snippet,  :only => [:edit, :update, :destroy]

  def index
    return redirect_to :action => :new if @cms_site.snippets.count == 0
    @cms_snippets = @cms_site.snippets.all(:order => 'label')
  end

  def new
    render
  end

  def edit
    render
  end

  def create
    @cms_snippet.save!
    flash[:notice] = 'Snippet created'
    redirect_to (params[:commit] ? {:action => :index} : {:action => :edit, :id => @cms_snippet})
  rescue ActiveRecord::RecordInvalid
    flash.now[:error] = 'Failed to create snippet'
    render :action => :new
  end

  def update
    @cms_snippet.update_attributes!(params[:cms_snippet])
    flash[:notice] = 'Snippet updated'
    redirect_to (params[:commit] ? {:action => :index} : {:action => :edit, :id => @cms_snippet})
  rescue ActiveRecord::RecordInvalid
    flash.now[:error] = 'Failed to update snippet'
    render :action => :edit
  end

  def destroy
    @cms_snippet.destroy
    flash[:notice] = 'Snippet deleted'
    redirect_to :action => :index
  end

protected

  def build_cms_snippet
    @cms_snippet = @cms_site.snippets.new(params[:cms_snippet])
  end

  def load_cms_snippet
    @cms_snippet = @cms_site.snippets.find(params[:id])
  rescue ActiveRecord::RecordNotFound
    flash[:error] = 'Snippet not found'
    redirect_to :action => :index
  end
end
