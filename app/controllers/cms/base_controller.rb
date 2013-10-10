class Cms::BaseController < ApplicationController
  
  before_action :load_cms_site
  
protected

  def load_cms_site
    @cms_site ||= if params[:site_id]
      ::Cms::Site.find_by_id(params[:site_id])
    else
      ::Cms::Site.find_site(request.host_with_port.downcase, request.fullpath)
    end
    
    if @cms_site
      if params[:cms_path].present?
        params[:cms_path].gsub!(/^#{@cms_site.path}/, '')
        params[:cms_path].to_s.gsub!(/^\//, '')
      end
      I18n.locale = @cms_site.locale
    else
      I18n.locale = I18n.default_locale
      raise ActionController::RoutingError.new('Site Not Found')
    end
  end

end