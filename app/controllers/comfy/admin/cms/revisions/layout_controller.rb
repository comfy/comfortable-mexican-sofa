# frozen_string_literal: true

class Comfy::Admin::Cms::Revisions::LayoutController < Comfy::Admin::Cms::Revisions::BaseController
private

  def load_record
    @record = @site.layouts.find(params[:layout_id])
  rescue ActiveRecord::RecordNotFound
    flash[:danger] = I18n.t('comfy.admin.cms.revisions.record_not_found')
    redirect_to comfy_admin_cms_site_layouts_path(@site)
  end

  def record_path
    edit_comfy_admin_cms_site_layout_path(@site, @record)
  end
end
