class Comfy::Admin::Cms::RevisionsController < Comfy::Admin::Cms::BaseController

  before_action :load_record
  before_action :load_revision, except: :index
  before_action :authorize

  helper_method :record_path

  def index
    redirect_to action: :show, id: @record.revisions.order(created_at: :desc).first.try(:id) || 0
  end

  def show
    case @record
    when Comfy::Cms::Page, Comfy::Cms::Translation
      @current_content    = @record.fragments.inject({}){|c, b| c[b.identifier] = b.content; c }
      @versioned_content  = @record.fragments.inject({}){|c, b| c[b.identifier] = @revision.data['fragments_attributes'].detect{|r| r[:identifier] == b.identifier}.try(:[], :content); c }
    else
      @current_content    = @record.revision_fields.inject({}){|c, f| c[f] = @record.send(f); c }
      @versioned_content  = @record.revision_fields.inject({}){|c, f| c[f] = @revision.data[f]; c }
    end
  end

  def revert
    @record.restore_from_revision(@revision)
    flash[:success] = I18n.t('comfy.admin.cms.revisions.reverted')
    redirect_to record_path
  end

protected

  def load_record
    @record = if params[:layout_id]
      ::Comfy::Cms::Layout.find(params[:layout_id])
    elsif params[:translation_id]
      ::Comfy::Cms::Translation.find(params[:translation_id])
    elsif params[:page_id]
      ::Comfy::Cms::Page.find(params[:page_id])
    elsif params[:snippet_id]
      ::Comfy::Cms::Snippet.find(params[:snippet_id])
    end

  rescue ActiveRecord::RecordNotFound
    flash[:danger] = I18n.t('comfy.admin.cms.revisions.record_not_found')
    redirect_to comfy_admin_cms_path
  end

  def load_revision
    @revision = @record.revisions.find(params[:id])
  rescue ActiveRecord::RecordNotFound
    flash[:danger] = I18n.t('comfy.admin.cms.revisions.not_found')
    redirect_to record_path
  end

  def record_path(record = @record)
    case record
      when ::Comfy::Cms::Layout
        edit_comfy_admin_cms_site_layout_path(@site, @record)
      when ::Comfy::Cms::Page
        edit_comfy_admin_cms_site_page_path(@site, @record)
      when ::Comfy::Cms::Translation
        edit_comfy_admin_cms_site_page_translation_path(@site, @record.page, @record)
      when ::Comfy::Cms::Snippet
        edit_comfy_admin_cms_site_snippet_path(@site, @record)
    end
  end
end
