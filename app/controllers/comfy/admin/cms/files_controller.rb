# frozen_string_literal: true

class Comfy::Admin::Cms::FilesController < Comfy::Admin::Cms::BaseController
  include ::Comfy::ReorderAction
  self.reorder_action_resource = ::Comfy::Cms::File

  include ActionView::Helpers::NumberHelper

  before_action :build_file,  only: %i[new create]
  before_action :load_file,   only: %i[edit update destroy]
  before_action :authorize

  def index
    files_scope = @site.files.with_attached_attachment

    case params[:source]

    # Integration with Redactor 1.0 Wysiwyg
    when 'redactor'
      file_scope  = files_scope.limit(100).order(:position)
      file_hashes =
        case params[:type]
        when 'image'
          file_scope.with_images.collect do |file|
            { thumb: url_for(file.attachment.variant(combine_options: Comfy::Cms::File::VARIANT_SIZE[:redactor])),
              image: url_for(file.attachment),
              title: file.label }
          end
        else
          file_scope.collect do |file|
            { title: file.label,
              name: file.attachment.filename,
              link: url_for(file.attachment),
              size: number_to_human_size(file.attachment.byte_size) }
          end
        end

      render json: file_hashes

    else
      files_scope = files_scope
        .includes(:categories)
        .for_category(params[:categories])
        .order('comfy_cms_files.position')
      @files = comfy_paginate(files_scope, per_page: 50)
    end
  end

  def new
    render
  end

  def create
    categories_scope = @site.categories.of_type('Comfy::Cms::File')

    if params[:categories]
      ids = categories_scope.where(label: params[:categories]).pluck(:id)
      @file.category_ids = ids
    end

    # Automatically tagging upload if it's done through redactor
    if params[:source] == 'redactor'
      category = categories_scope.find_or_create_by(label: 'wysiwyg')
      @file.category_ids = [category.id]
    end

    @file.save!

    case params[:source]
    when 'plupload'
      render partial: 'file', object: @file
    when 'redactor'
      render json: {
        filelink: url_for(@file.attachment),
        filename: @file.attachment.filename
      }
    else
      flash[:success] = I18n.t('comfy.admin.cms.files.created')
      redirect_to action: :edit, id: @file
    end
  rescue ActiveRecord::RecordInvalid
    case params[:source]
    when 'plupload'
      render body: @file.errors.full_messages.to_sentence, status: :unprocessable_entity
    when 'redactor'
      render body: nil, status: :unprocessable_entity
    else
      flash.now[:danger] = I18n.t('comfy.admin.cms.files.creation_failure')
      render action: :new
    end
  end

  def edit
    render
  end

  def update
    if @file.update(file_params)
      flash[:success] = I18n.t('comfy.admin.cms.files.updated')
      redirect_to action: :edit, id: @file
    else
      flash.now[:danger] = I18n.t('comfy.admin.cms.files.update_failure')
      render action: :edit
    end
  end

  def destroy
    @file.destroy
    respond_to do |format|
      format.js
      format.html do
        flash[:success] = I18n.t('comfy.admin.cms.files.deleted')
        redirect_to action: :index
      end
    end
  end

protected

  def build_file
    @file = @site.files.new(file_params)
  end

  def load_file
    @file = @site.files.find(params[:id])
  rescue ActiveRecord::RecordNotFound
    flash[:danger] = I18n.t('comfy.admin.cms.files.not_found')
    redirect_to action: :index
  end

  def file_params
    file = params[:file]
    unless file.is_a?(Hash) || file.respond_to?(:to_unsafe_hash)
      params[:file] = {}
      params[:file][:file] = file
    end
    params.fetch(:file, {}).permit!
  end
end
