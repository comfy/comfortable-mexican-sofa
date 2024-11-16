# frozen_string_literal: true

class Comfy::Admin::Cms::Revisions::BaseController < Comfy::Admin::Cms::BaseController
  helper_method :record_path

  before_action :load_record
  before_action :load_revision, except: :index
  before_action :authorize

  def index
    revision = @record.revisions.order(created_at: :desc).first
    if revision
      redirect_to action: :show, id: revision.id
    else
      redirect_to record_path
    end
  end

  def show
    @current_content    = @record.revision_fields.each_with_object({}) { |f, c| c[f] = @record.send(f) }
    @versioned_content  = @record.revision_fields.each_with_object({}) { |f, c| c[f] = @revision.data[f] }

    render 'comfy/admin/cms/revisions/show'
  end

  def revert
    @record.restore_from_revision(@revision)
    flash[:success] = I18n.t('comfy.admin.cms.revisions.reverted')
    redirect_to record_path
  end

protected

  def load_record
    raise 'not implemented'
  end

  def load_revision
    @revision = @record.revisions.find(params[:id])
  rescue ActiveRecord::RecordNotFound
    flash[:danger] = I18n.t('comfy.admin.cms.revisions.not_found')
    redirect_to record_path
  end

  def record_path
    raise 'not implemented'
  end
end
