class CmsAdmin::SnippetsController < CmsAdmin::BaseController
  before_filter :load_cms_snippet,
    :only => [:edit, :update, :destroy]
  before_filter :build_cms_snippet,
    :only => [:new, :create]

  def index
    @cms_snippets = CmsSnippet.all
  end

  def new
    # ...
  end

  def edit
    # ...
  end

  def create
    @cms_snippet.save!
    redirect_to({ :action => :edit, :id => @cms_snippet }, :notice => 'Snippet created')
  rescue ActiveRecord::RecordInvalid
    render :action => :new
  end

  def update
    @cms_snippet.update_attributes!(params[:cms_snippet])
    redirect_to({ :action => :edit, :id => @cms_snippet }, :notice => 'Snippet updated')
  rescue ActiveRecord::RecordInvalid
    render :action => :edit
  end

  def destroy
    @cms_snippet.destroy
    redirect_to({ :action => :index }, :notice => 'Snippet removed')
  end

protected
  def load_cms_snippet
    @cms_snippet = CmsSnippet.find(params[:id])
  rescue ActiveRecord::RecordNotFound
    render_not_found
  end

  def build_cms_snippet
    params[:cms_snippet] ||= { }
    @cms_snippet = CmsSnippet.new(params[:cms_snippet])
  end
end
