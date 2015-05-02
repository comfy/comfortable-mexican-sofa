class Comfy::Cms::BaseController < ApplicationController

  before_action :load_cms_site

protected

  # Loads the cms site and sets I18n locale.
  #
  # The locale is set to cms site locale by default. If no cms site can be loaded
  # the locale is set to *I18n.default_locale*. You can create a method <tt>cms_locale</tt>
  # in your *ApplicationController* to return the locale differently.
  # For example *:de* if the top level domain is *de*. When the cms is laoding
  # pages later it tries to find pages and translations matching I18n locale.
  def load_cms_site
    @cms_site ||= if params[:site_id]
      ::Comfy::Cms::Site.find_by_id(params[:site_id])
    else
      ::Comfy::Cms::Site.find_site(request.host_with_port.downcase, request.fullpath)
    end

    if @cms_site
      if @cms_site.path.present? && !params[:site_id]
        if params[:cms_path] && params[:cms_path].match(/\A#{@cms_site.path}/)
          params[:cms_path].gsub!(/\A#{@cms_site.path}/, '')
          params[:cms_path] && params[:cms_path].gsub!(/\A\//, '')
        else
          raise ActionController::RoutingError.new('Site Not Found')
        end
      end
      I18n.locale = cms_locale rescue @cms_site.locale
    else
      I18n.locale = cms_locale rescue I18n.default_locale
      raise ActionController::RoutingError.new('Site Not Found')
    end
  end

end
