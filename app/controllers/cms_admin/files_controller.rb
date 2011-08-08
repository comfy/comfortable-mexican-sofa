class CmsAdmin::FilesController < CmsAdmin::BaseController
  
  skip_before_filter :load_fixtures
  
  before_filter :build_file, :only => [:new, :create]
  before_filter :load_file,  :only => [:edit, :update, :destroy]
  
  def index
    @files = @site.files
  end
  
  def new
    render
  end
  
  def create
    @file = @site.files.create!(:file => params[:file])
    render :partial => 'file', :object => @file
  rescue ActiveRecord::RecordInvalid
    render :nothing => true, :status => :bad_request
  end
  
  def destroy
    @file.destroy
  end
  
protected

  def build_file
    @file = @site.files.new(params[:file])
  end
  
  def load_file
    @file = @site.files.find(params[:id])
  rescue ActiveRecord::RecordNotFound
    render :nothing => true
  end
end
