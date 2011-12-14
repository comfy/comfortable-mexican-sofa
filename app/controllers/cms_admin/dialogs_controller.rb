class CmsAdmin::DialogsController < CmsAdmin::BaseController
  
  TEMPLATES = %w(image link)
  
  def show
    if template = TEMPLATES.include?(params[:type])? params[:type] : nil
      render :template => "cms_admin/dialogs/#{template}", :layout => false
    else
      render :nothing => true
    end
  end
  
end