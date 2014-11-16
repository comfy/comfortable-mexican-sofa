class Comfy::Admin::Cms::RevisionsController < Comfy::Admin::Cms::BaseController

  before_action :load_record
  before_action :load_revision, :except => :index
  before_action :authorize

  def index
    redirect_to :action => :show, :id => @record.revisions.first.try(:id) || 0
  end

  def show
    case @record
    when Comfy::Cms::Page
      @current_content    = @record.blocks.inject({}){|c, b| c[b.identifier] = b.content; c }
      @versioned_content  = @record.blocks.inject({}){|c, b| c[b.identifier] = @revision.data['blocks_attributes'].detect{|r| r[:identifier] == b.identifier}.try(:[], :content); c }
    else
      @current_content    = @record.revision_fields.inject({}){|c, f| c[f] = @record.send(f); c }
      @versioned_content  = @record.revision_fields.inject({}){|c, f| c[f] = @revision.data[f]; c }
    end
  end

  def revert
    @record.restore_from_revision(@revision)
    flash[:success] = I18n.t('comfy.admin.cms.revisions.reverted')
    redirect_to_record
  end

protected

  def load_record
    @record = if params[:layout_id]
      ::Comfy::Cms::Layout.find(params[:layout_id])
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
    redirect_to_record
  end

  def redirect_to_record
    redirect_to case @record
      when ::Comfy::Cms::Layout  then edit_comfy_admin_cms_site_layout_path(@site, @record)
      when ::Comfy::Cms::Page    then edit_comfy_admin_cms_site_page_path(@site, @record)
      when ::Comfy::Cms::Snippet then edit_comfy_admin_cms_site_snippet_path(@site, @record)
    end
  end

end