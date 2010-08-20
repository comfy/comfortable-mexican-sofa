class CmsAdmin::BaseController < ApplicationController

  before_filter :authenticate

  layout 'cms_admin'

  def index
    # the jQuery in utilities.js uses the current path to define the scope (i.e: layouts vs. pages).
    # So having /cms-admin as a path for pages will break the js.
    redirect_to cms_admin_pages_path
  end

  def save_tree_state(object)
    name = object.class.name.underscore.to_sym
    session[name] ||= []
    session[name] = if session[name].include?(object.id)
      session[name] - [object.id]
    else
      session[name] + [object.id]
    end
  end

  def js_helper_installed?(name, library = nil)
    File.exists?(File.expand_path("public/javascripts/#{name}/#{library||name}.js", Rails.root))
  end
  helper_method :js_helper_installed?

protected

  def authenticate
    authenticate_or_request_with_http_basic do |username, password|
      username == ComfortableMexicanSofa::Config.http_auth_username && 
      password == ComfortableMexicanSofa::Config.http_auth_password
    end if ComfortableMexicanSofa::Config.http_auth_enabled
  end

end
