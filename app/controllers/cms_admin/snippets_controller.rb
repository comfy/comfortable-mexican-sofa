class CmsAdmin::SnippetsController < CmsAdmin::BaseController
  
  before_filter :build_cms_snippet, :only => [:new, :create]
  before_filter :load_cms_snippet,  :only => [:edit, :update, :destroy]
  
  def index
    @cms_snippets = CmsSnippet.all(:order => 'label')
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
    redirect_to :action => :edit, :id => @cms_snippet
  rescue ActiveRecord::RecordInvalid
    flash.now[:error] = 'Failed to create snippet'
    render :action => :new
  end
  
  def update
    @cms_snippet.update_attributes!(params[:cms_snippet])
    flash[:notice] = 'Snippet updated'
    redirect_to :action => :edit, :id => @cms_snippet
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
    @cms_snippet = CmsSnippet.new(params[:cms_snippet])
  end
  
  def load_cms_snippet
    @cms_snippet = CmsSnippet.find(params[:id])
  rescue ActiveRecord::RecordNotFound
    flash[:error] = 'Snippet not found'
    redirect_to :action => :index
  end
end
