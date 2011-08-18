class CmsAdmin::FilesController < CmsAdmin::BaseController
  
  skip_before_filter :load_fixtures
  
  before_filter :load_file, :only => [:edit, :update, :destroy]
  
  def index
    @files = @site.files
  end
  
  def new
    @file = @site.files.new
  end
  
  def create
    params[:file][:file].each do |file|
      @site.files.create!(:file => file)
    end
    
    flash[:notice] = I18n.t('cms.files.created')
    redirect_to :action => :index
  rescue ActiveRecord::RecordInvalid
    flash.now[:error] = I18n.t('cms.files.creation_failure')
    render :action => :new
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
    render :nothing => true
  end
end
