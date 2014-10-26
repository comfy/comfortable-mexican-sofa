class Comfy::Admin::Cms::FilesController < Comfy::Admin::Cms::BaseController

  skip_before_action :load_fixtures

  before_action :build_file,  :only => [:new, :create]
  before_action :load_file,   :only => [:edit, :update, :destroy]
  before_action :set_column_layout



  def index
    @files = @site.files.not_page_file.includes(:categories).for_category(params[:category]).order('comfy_cms_files.position')
  end

  def new
  end

  # TODO: I don't think we need js create format...

  def create
    respond_to do |format|
      if @file.save
        format.html do
          flash[:success] = I18n.t('comfy.admin.cms.files.created')
          redirect_to :action => :edit, :id => @file
        end
        # format.js { render :action => 'show', :status => :created }
        format.plupload { render :text => render_to_string(:partial => 'file', :object => @file, :formats => [:html]) }
      else
        format.html do
          flash.now[:danger] = I18n.t('comfy.admin.cms.files.creation_failure')
          render :action => :new
        end
        # format.js { render :json => @file.errors, :status => :unprocessable_entity }
        format.plupload { render :text => @file.errors.full_messages.to_sentence, :status => :unprocessable_entity }
      end
    end
  end

  def update
    if @file.update(file_params)
      flash[:success] = I18n.t('comfy.admin.cms.files.updated')
      redirect_to :action => :edit, :id => @file
    else
      flash.now[:danger] = I18n.t('comfy.admin.cms.files.update_failure')
      render :action => :edit
    end
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
    @file = @site.files.new(file_params)
  end

  def load_file
    @file = @site.files.find(params[:id])
  rescue ActiveRecord::RecordNotFound
    flash[:danger] = I18n.t('comfy.admin.cms.files.not_found')
    redirect_to :action => :index
  end

  def file_params
    params.fetch(:file, {}).permit!
  end

  # The CMS files library can be accessed in two modes +fullpage+ and +modal+.
  # In +modal+ the library is opend in a iframe of a modal window making it act
  # like a actual file browser and the users stay on the page where they opened
  # the library. In +fullpage+ the files library is opened like any other page.
  def set_column_layout
    @column_layout = :flat if modal_mode?
  end

  def modal_mode?
    !!params[:modal]
  end
  helper_method :modal_mode?

  # If we are in modal mode we need to add the parameter that identifies the
  # modal mode to every url we generate.
  # For some reason when added as a method and made a helper via <tt>helper_method</tt>
  # it would always generate absolute urls with +http://test.host+ in test env
  # which wasn't what we want :(
  module UrlForHelper
    def url_for(options = {})
      if modal_mode?
        modal_options = {:modal => true}
        options = case options
        when String
          uri = Addressable::URI.new
          uri.query_values = modal_options
          options + (options.index('?').nil? ? '?' : '&') + uri.query
        when Hash
          options.reverse_merge(modal_options)
        else
          options
        end
      end
      super
    end
  end
  helper UrlForHelper

end
