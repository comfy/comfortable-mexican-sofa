class CmsAdmin::UploadsController < CmsAdmin::BaseController
  before_filter :load_cms_upload,
    :only => :destroy
  
  def index
  end
  
  def create
    @cms_upload = CmsUpload.new(:uploaded_file => params[:file])
    if @cms_upload.save
      render(:partial => 'cms_admin/uploads/upload', :object => @cms_upload)
    else
      render :nothing => true
    end
  end
  
  def destroy
    @cms_upload.destroy
  end

protected
  def load_cms_upload
    @cms_upload = CmsUpload.find(params[:id])
  rescue ActiveRecord::RecordNotFound
    render :nothing => true
  end
end
