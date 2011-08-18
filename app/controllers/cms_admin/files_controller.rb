class CmsAdmin::FilesController < CmsAdmin::BaseController
  
  skip_before_filter :load_fixtures
  
  before_filter :load_file, :only => [:edit, :update, :destroy]
  
  def index
    return redirect_to :action => :new if @site.files.count == 0
    @files = @site.files.all(:order => 'label')
  end
  
  def new
    @file = @site.files.new
  end
  
  def create
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
  rescue ActiveRecord::RecordInvalid
    flash.now[:error] = I18n.t('cms.files.creation_failure')
    render :action => :new
  end
  
  def update
    @file.update_attributes!(params[:file])
    flash[:notice] = I18n.t('cms.files.updated')
    redirect_to :action => :edit, :id => @file
  rescue ActiveRecord::RecordInvalid
    flash.now[:error] = I18n.t('cms.files.update_failure')
    render :action => :edit
  end
  
  def destroy
    @file.destroy
    flash[:notice] = I18n.t('cms.files.deleted')
    redirect_to :action => :index
  end
  
protected
  
  def load_file
    @file = @site.files.find(params[:id])
  rescue ActiveRecord::RecordNotFound
    flash[:error] = I18n.t('cms.files.not_found')
    redirect_to :action => :index
  end
end
