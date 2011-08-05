class CmsAdmin::FilesController < CmsAdmin::BaseController
  
  skip_before_filter :load_fixtures
  
  before_filter :load_file, :only => :destroy
  
  def index
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
  
  def load_file
    @file = @site.files.find(params[:id])
  rescue ActiveRecord::RecordNotFound
    render :nothing => true
  end
end
