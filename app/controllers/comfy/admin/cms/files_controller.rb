# frozen_string_literal: true

class Comfy::Admin::Cms::FilesController < Comfy::Admin::Cms::BaseController

  include ::Comfy::ReorderAction
  self.reorder_action_resource = ::Comfy::Cms::File

  include ActionView::Helpers::NumberHelper

  before_action :load_file,   only: %i[edit update destroy]
  before_action :authorize

  def index
    files_scope = @site.files.with_attached_attachment

    case params[:source]

    # Integration with Redactor 3 Wysiwyg
    when "redactor"
      file_scope  = files_scope.limit(100).order(:position)
      file_hashes =
        case params[:type]
        when "image"
          file_scope.with_images.collect do |file|
            { thumb: url_for(file.attachment.variant(combine_options: Comfy::Cms::File::VARIANT_SIZE[:redactor])),
              url:   url_for(file.attachment),
              title: file.label,
              id:    file.id }
          end
        else
          file_scope.collect do |file|
            { title:  file.label,
              name:   file.attachment.filename,
              url:    url_for(file.attachment),
              size:   number_to_human_size(file.attachment.byte_size),
              id:     file.id }
          end
        end

      render json: file_hashes

    else
      files_scope = files_scope
        .includes(:categories)
        .for_category(params[:categories])
        .order(:position)
      @files = comfy_paginate(files_scope, per_page: 50)
    end
  end

  def new
    @file = @site.files.new(file_params)
  end

  def create
    case params[:source]
    when "redactor"
      _create_redactor
    when "plupload"
      _create_plupload
    else
      _create
    end
  end

  def edit
  end

  def update
    if @file.update(file_params)
      flash[:success] = I18n.t("comfy.admin.cms.files.updated")
      redirect_to action: :edit, id: @file
    else
      flash.now[:danger] = I18n.t("comfy.admin.cms.files.update_failure")
      render action: :edit
    end
  end

  def destroy
    @file.destroy
    respond_to do |format|
      format.js
      format.html do
        flash[:success] = I18n.t("comfy.admin.cms.files.deleted")
        redirect_to action: :index
      end
    end
  end

protected

  def _create_redactor
    files = @site.files.new(files_params)
    # set category ids
    categories_scope = @site.categories.of_type("Comfy::Cms::File")
    category_ids = [ categories_scope.find_or_create_by(label: "wysiwyg").id ]
    if params[:categories].present?
      category_ids.concat( categories_scope.where(label: params[:categories]).pluck(:id) )
    end

    files.each do |file|
      file.category_ids = category_ids
      file.save!
    end

    result =
        files.each_with_object({}) do |file, hash|
          hash["file-#{file.id}"] = {
              url: url_for(file.attachment),
              id: file.id
          }
        end
    render json: result
  rescue ActiveRecord::RecordInvalid
    file =
        files&.detect do |file|
          file.errors.any?
        end
    render json: {error: true, message: file && file.errors.full_messages.to_sentence}, status: :unprocessable_entity
  end

  def _create_plupload
    @file = @site.files.new(file_params)
    # set category ids
    categories_scope = @site.categories.of_type("Comfy::Cms::File")
    category_ids = []
    if params[:categories].present?
      category_ids.concat( categories_scope.where(label: params[:categories]).pluck(:id) )
    end
    @file.category_ids = category_ids

    @file.save!

    render partial: "file", object: @file
  rescue ActiveRecord::RecordInvalid
    render body: @file.errors.full_messages.to_sentence, status: :unprocessable_entity
  end

  def _create
    @file = @site.files.new(file_params)
    # set category ids
    categories_scope = @site.categories.of_type("Comfy::Cms::File")
    category_ids = []
    if params[:categories].present?
      category_ids.concat( categories_scope.where(label: params[:categories]).pluck(:id) )
    end
    @file.category_ids = category_ids

    @file.save!

    flash[:success] = I18n.t("comfy.admin.cms.files.created")
    redirect_to action: :edit, id: @file
  rescue ActiveRecord::RecordInvalid
    flash.now[:danger] = I18n.t("comfy.admin.cms.files.creation_failure")
    render action: :new
  end

  def load_file
    @file = @site.files.find(params[:id])
  rescue ActiveRecord::RecordNotFound
    flash[:danger] = I18n.t("comfy.admin.cms.files.not_found")
    redirect_to action: :index
  end

  def file_params
    file = params[:file]
    # new() needs a file hash to work, so create an "empty" (at least one attribute must be passed) one if no file
    # attributes were passed.
    unless file.is_a?(Hash) || file.respond_to?(:to_unsafe_hash)
      params[:file] = {label: nil}
    end
    params.require(:file).permit(:label, :file, :description, category_ids: [])
  end

  def files_params
    # convert `file: [<upload>, <upload2>, ...]` to `[{file: <upload>}, {file: <upload2>}, ...]`
    params.require(:file).map! { |file| {file: file} }
  end

end
