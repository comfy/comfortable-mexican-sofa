class Comfy::Admin::Cms::FilesController < Comfy::Admin::Cms::BaseController

  skip_before_action :load_fixtures

  before_action :build_file,  :only => [:new, :create]
  before_action :load_file,   :only => [:edit, :update, :destroy]

  def index
    @files = @site.files.not_page_file.includes(:categories).for_category(params[:category]).
        search_by(params[:search]).page(params[:page])

    if params[:ajax]
      if params[:not_images]
        files = @files.not_images.collect do |file|
          { :label    => file.label,
            :filename => file.file_file_name,
            :url      => file.file.url }
        end
      else
        files = @files.images.collect do |file|
          { :thumb  => file.file.url(:cms_thumb),
            :image  => file.file.url }
        end
      end
    end

    respond_to do |format|
      format.html { params[:ajax] ? render(:json => files) : (redirect_to(:action => :new) if @site.files.count == 0) }
      format.json { render(:json => files) }
      format.js
    end
  end

  def new
  end

  def edit
  end

  def create
    @files = []

    files = [file_params[:file]].flatten
    files.each_with_index do |file, i|
      label = (files.size > 1 && file_params[:label].present?) ?
        "#{file_params[:label]} #{i + 1}" :
        file_params[:label]
      @file = @site.files.create!(file_params.except(:file, :label).merge(
        :file         => file,
        :label        => label
      ))
      @files << @file
    end

    if params[:ajax]
      view = render_to_string(:partial => 'comfy/admin/cms/files/file', :collection => @files, :layout => false)
      render :json => {:filelink => @file.file.url, :filename => @file.file_file_name, :view => view.gsub("\n", '')}
    else
      flash[:success] = I18n.t('comfy.admin.cms.files.created')
      redirect_to :action => :edit, :id => @file
    end

  rescue ActiveRecord::RecordInvalid
    if params[:ajax]
      render :nothing => true, :status => :unprocessable_entity
    else
      flash.now[:danger] = I18n.t('comfy.admin.cms.files.creation_failure')
      render :action => :new
    end
  end

  def update
    @file.update_attributes!(file_params)
    flash[:success] = I18n.t('comfy.admin.cms.files.updated')
    redirect_to :action => :edit, :id => @file
  rescue ActiveRecord::RecordInvalid
    flash.now[:danger] = I18n.t('comfy.admin.cms.files.update_failure')
    render :action => :edit
  end

  def destroy
    @file.destroy
    respond_to do |format|
      format.js
      format.html do
        flash[:success] = I18n.t('comfy.admin.cms.files.deleted')
        redirect_to :action => :index
      end
    end
  end

  def reorder
    (params[:comfy_cms_file] || []).each_with_index do |id, index|
      if (cms_file = ::Comfy::Cms::File.find_by_id(id))
        cms_file.update_column(:position, index)
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
    flash[:danger] = I18n.t('comfy.admin.cms.files.not_found')
    redirect_to :action => :index
  end

  def file_params
    # single file upload
    unless (file = params[:file]).is_a?(Hash)
      params[:file] = { }
      params[:file][:file] = [file]
    end
    params.fetch(:file, {}).permit!
  end
end
