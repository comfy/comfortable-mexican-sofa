class CmsAdmin::FilesController < CmsAdmin::BaseController
  
  skip_before_filter :load_fixtures
  
  before_filter :build_file,  :only => [:new, :create]
  before_filter :load_file,   :only => [:edit, :update, :destroy]
  
  def index
    @files = @site.files.includes(:categories).for_category(params[:category]).order('cms_files.position')
    
    if params[:ajax]
      files = @files.images.collect do |file|
        { :thumb  => file.file.url(:cms_thumb),
          :image  => file.file.url }
      end
      render :json => files
    else
      return redirect_to :action => :new if @site.files.count == 0
    end
  end
  
  def new
    render
  end

  def create
    @files = []
    
    # Sometimes params[:file] comes in as a single file object
    unless params[:file].is_a?(Hash)
      uploaded_file = params[:file]
      params[:file] = { }
      params[:file][:file] = [uploaded_file]
    end
    
    file_array  = params[:file][:file] || [nil]
    label       = params[:file][:label]
        
    file_array.each_with_index do |file, i|
      file_params = params[:file].merge(:file => file)
      if file_array.size > 1 && file_params[:label].present?
        label = file_params[:label] + " #{i + 1}"
      end
      @file = @site.files.create!(file_params.merge(:label => label))
      @files << @file
    end
    
    if params[:ajax]
      view = render_to_string(:partial => 'cms_admin/files/file', :collection => @files, :layout => false)
      render :json => {:filelink => @file.file.url, :view => view.gsub("\n", '')}
    else
      flash[:success] = I18n.t('cms.files.created')
      redirect_to :action => :edit, :id => @file
    end
    
  rescue ActiveRecord::RecordInvalid
    logger.detailed_error($!)
    if params[:ajax]
      render :nothing => true, :status => :unprocessable_entity
    else
      flash.now[:error] = I18n.t('cms.files.creation_failure')
      render :action => :new
    end
  end
  
  def update
    @file.update_attributes!(params[:file])
    flash[:success] = I18n.t('cms.files.updated')
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
        flash[:success] = I18n.t('cms.files.deleted')
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

  def build_file
    @file = @site.files.new
  end
  
  def load_file
    @file = @site.files.find(params[:id])
  rescue ActiveRecord::RecordNotFound
    flash[:error] = I18n.t('cms.files.not_found')
    redirect_to :action => :index
  end
end
