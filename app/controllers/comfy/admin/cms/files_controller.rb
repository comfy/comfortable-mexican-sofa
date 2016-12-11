class Comfy::Admin::Cms::FilesController < Comfy::Admin::Cms::BaseController

  include ActionView::Helpers::NumberHelper

  before_action :build_file,  :only => [:new, :create]
  before_action :load_file,   :only => [:edit, :update, :destroy]
  before_action :authorize

  def index
    case params[:source]
    when 'redactor'
      file_scope  = @site.files.limit(100).order('created_at DESC')
      file_hashes = case params[:type]
      when 'image'
        file_scope.images.collect do |image|
          { :thumb => image.file.url(:cms_thumb),
            :image => image.file.url,
            :title => image.label }
        end
      else
        file_scope.collect do |file|
          { :title  => file.label,
            :name   => file.file_file_name,
            :link   => file.file.url,
            :size   => number_to_human_size(file.file_file_size) }
        end
      end
      render :json => file_hashes
    else
      files_scope = @site.files.not_page_file
        .includes(:categories)
        .for_category(params[:category])
        .order('comfy_cms_files.position')
      @files = comfy_paginate(files_scope, 50)
    end
  end

  def new
    render
  end

  def create
    if params[:category]
      ids = @site.categories.of_type('Comfy::Cms::File')
        .where(:label => params[:category])
        .each_with_object({}){|c, h| h[c.id] = 1}
      @file.category_ids = ids
    end
    
    @file.save!

    case params[:source]
    when 'plupload'
      render :body => render_to_string(:partial => 'file', :object => @file)
    when 'redactor'
      render :json => {:filelink => @file.file.url, :filename => @file.label}
    else
      flash[:success] = I18n.t('comfy.admin.cms.files.created')
      redirect_to :action => :edit, :id => @file
    end

  rescue ActiveRecord::RecordInvalid
    case params[:source]
    when 'plupload'
      render :body => @file.errors.full_messages.to_sentence, :status => :unprocessable_entity
    when 'redactor'
      render body: nil, :status => :unprocessable_entity
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
    head :ok
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
    file = params[:file]
    unless file.is_a?(Hash) || file.respond_to?(:to_unsafe_hash)
      params[:file] = { }
      params[:file][:file] = file
    end
    params.fetch(:file, {}).permit!
  end
end
