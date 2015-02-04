class Comfy::Admin::Cms::FilesController < Comfy::Admin::Cms::BaseController
  include ActionView::Helpers::NumberHelper

  before_action :build_file,  :only => [:new, :create]
  before_action :load_file,   :only => [:edit, :update, :destroy]
  before_action :authorize

  def index
    files_scope = @site.files.not_page_file
      .includes(:categories)
      .for_category(params[:category])
      .order('comfy_cms_files.position')

    files_scope = files_scope.images if params[:type] == 'image'

    @files = comfy_paginate(files_scope, 50)
  end

  def new
    render
  end

  def create
    @file.save!

    case params[:source]
    when 'plupload'
      render :text => render_to_string(:partial => 'file', :object => @file)
    else
      flash[:success] = I18n.t('comfy.admin.cms.files.created')
      redirect_to :action => :edit, :id => @file
    end

  rescue ActiveRecord::RecordInvalid
    case params[:source]
    when 'plupload'
      render :text => @file.errors.full_messages.to_sentence, :status => :unprocessable_entity
    else
      flash.now[:danger] = I18n.t('comfy.admin.cms.files.creation_failure')
      render :action => :new
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
    unless (file = params[:file]).is_a?(Hash)
      params[:file] = { }
      params[:file][:file] = file
    end
    params.fetch(:file, {}).permit!
  end
end
