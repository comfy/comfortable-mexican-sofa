class CmsAdmin::UploadsController < CmsAdmin::BaseController
  
  before_filter :load_cms_upload, :only => :destroy
  
  def index
    render
  end
  
  def create
    @cms_upload = @cms_site.uploads.create!(:file => params[:file])
    render :partial => 'file', :object => @cms_upload
  rescue ActiveRecord::RecordInvalid
    render :nothing => true, :status => :bad_request
  end
  
  def destroy
    @cms_upload.destroy
  end
  
protected
  
  def load_cms_upload
    @cms_upload = @cms_site.uploads.find(params[:id])
  rescue ActiveRecord::RecordNotFound
    render :nothing => true
  end
end
