class CmsAdmin::RevisionsController < CmsAdmin::BaseController
  
  before_filter :load_record
  before_filter :load_revision, :except => :index
  
  def index
    redirect_to :action => :show, :id => @record.revisions.first.try(:id) || 0
  end
  
  def show
    case @record
    when Cms::Page
      @current_content    = @record.blocks.inject({}){|c, b| c[b.label] = b.content; c }
      @versioned_content  = @record.blocks.inject({}){|c, b| c[b.label] = @revision.data['blocks_attributes'].detect{|r| r[:label] == b.label}.try(:[], :content); c }
    else
      @current_content    = @record.revision_fields.inject({}){|c, f| c[f] = @record.send(f); c }
      @versioned_content  = @record.revision_fields.inject({}){|c, f| c[f] = @revision.data[f]; c }
    end
  end
  
  def revert
    @record.restore_from_revision(@revision)
    flash[:notice] = I18n.t('cms.revisions.reverted')
    redirect_to_record
  end
  
protected
  
  def load_record
    @record = if params[:layout_id]
      Cms::Layout.find(params[:layout_id])
    elsif params[:page_id]
      Cms::Page.find(params[:page_id])
    elsif params[:snippet_id]
      Cms::Snippet.find(params[:snippet_id])
    end
  rescue ActiveRecord::RecordNotFound
    flash[:error] = I18n.t('cms.revisions.record_not_found')
    redirect_to cms_admin_path
  end
  
  def load_revision
    @revision = @record.revisions.find(params[:id])
  rescue ActiveRecord::RecordNotFound
    flash[:error] = I18n.t('cms.revisions.not_found')
    redirect_to_record
  end
  
  def redirect_to_record
    redirect_to case @record
      when Cms::Layout  then edit_cms_admin_site_layout_path(@site, @record)
      when Cms::Page    then edit_cms_admin_site_page_path(@site, @record)
      when Cms::Snippet then edit_cms_admin_site_snippet_path(@site, @record)
    end
  end
  
end