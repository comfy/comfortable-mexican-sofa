class CmsAdmin::FilesController < CmsAdmin::BaseController
  
  skip_before_filter :load_fixtures
  
  before_filter :load_file, :only => [:edit, :update, :destroy]
  
  def index
    return redirect_to :action => :new if @site.files.count == 0
    @files = @site.files.includes(:categories).for_category(params[:category]).all(:order => 'cms_files.position')
  end
  
  def new
    @file = @site.files.new
  end

  def create
    respond_to do |format|
      format.html do
        @file = @site.files.new
        file_array  = params[:file][:file] || [nil]
        label       = params[:file][:label]
        
        file_array.each_with_index do |file, i|
          file_params = params[:file].merge(:file => file)
          if file_array.size > 1 && file_params[:label].present?
            label = file_params[:label] + " #{i + 1}"
          end
          @file = @site.files.create!(file_params.merge(:label => label))
        end
        
        flash[:notice] = I18n.t('cms.files.created')
        redirect_to :action => :edit, :id => @file
      end
      format.js do
        # FIX: No idea why this cannot be simulated in the test
        io = Rails.env.test??
          request.env['RAW_POST_DATA'].clone :
          request.env['rack.input'].clone
        # Unfortunately, this ends up copying the data twice.
        # Once from the stream to the tempfile here, and second, in
        # the file to another tempfile down in PaperClip UploadFileAdapter..
        file = Tempfile.new(request.env["HTTP_X_FILE_NAME"])
        file.binmode
        # FileUtils.copy_stream ends up throwing Conversion Errors from ASCII-8BIT to UTF-8
        # FileUtils.copy_stream(io, file)
        while data = io.read(16*1024)
          file.write(data)
        end
        file.rewind
        # We use a delegation class on the file returned
        upload = ActionDispatch::Http::UploadedFile.new(
          :filename => request.env['HTTP_X_FILE_NAME'],
          :tempfile => file,
          :type     => request.env['CONTENT_TYPE'],
          :head     => request.headers # Not really needed
        )
        @file = @site.files.create!(
          (params[:file] || { }).merge(:file => upload)
        )
      end
    end
  rescue ActiveRecord::RecordInvalid
    logger.detailed_error($!)
    respond_to do |format|
      format.html do
        flash.now[:error] = I18n.t('cms.files.creation_failure')
        render :action => :new
      end
      format.js do
        render :nothing => true
      end
    end
  end
  
  def update
    @file.update_attributes!(params[:file])
    flash[:notice] = I18n.t('cms.files.updated')
    redirect_to :action => :edit, :id => @file
  rescue ActiveRecord::RecordInvalid
    logger.detailed_error($!)
    flash.now[:error] = I18n.t('cms.files.update_failure')
    render :action => :edit
  end
  
  def destroy
    @file.destroy
    respond_to do |format|
      format.js
      format.html do
        flash[:notice] = I18n.t('cms.files.deleted')
        redirect_to :action => :index
      end
    end
  end
  
  def reorder
    (params[:cms_file] || []).each_with_index do |id, index|
      if (cms_file = Cms::File.find_by_id(id))
        cms_file.update_attributes(:position => index)
      end
    end
    render :nothing => true
  end
  
protected
  
  def load_file
    @file = @site.files.find(params[:id])
  rescue ActiveRecord::RecordNotFound
    flash[:error] = I18n.t('cms.files.not_found')
    redirect_to :action => :index
  end
end
