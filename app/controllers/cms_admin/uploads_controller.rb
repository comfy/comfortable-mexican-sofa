class CmsAdmin::UploadsController < CmsAdmin::BaseController
  
  skip_before_filter :load_fixtures
  
  before_filter :load_upload, :only => :destroy
  
  def index
    render
  end
  
  def create
    @upload = @site.uploads.create!(:file => params[:file])
    render :partial => 'file', :object => @upload
  rescue ActiveRecord::RecordInvalid
    render :nothing => true, :status => :bad_request
  end
  
  def destroy
    @upload.destroy
  end
  
protected
  
  def load_upload
    @upload = @site.uploads.find(params[:id])
  rescue ActiveRecord::RecordNotFound
    render :nothing => true
  end
end
