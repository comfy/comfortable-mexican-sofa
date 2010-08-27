class CmsAdmin::BaseController < ApplicationController
  before_filter :register_asset_expansions
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

protected

  def authenticate
    authenticate_or_request_with_http_basic do |username, password|
      username == ComfortableMexicanSofa::Config.http_auth_username && 
      password == ComfortableMexicanSofa::Config.http_auth_password
    end if ComfortableMexicanSofa::Config.http_auth_enabled
  end
  
  def register_asset_expansions
    js_includes = ['jquery', 'jquery-ui', 'rails', 'cms'].collect{|f| ['cms', f].join('/')}
    js_includes += ['tiny_mce/jquery.tinymce', 'tiny_mce/tiny_mce', 'codemirror/codemirror', 'plupload/plupload.full.min' ].collect{|f| ['cms/3rdparty', f].join('/')}
    js_includes += ['rteditor', 'syntax_highlighter', 'uploader'].collect{|f| ['cms', f].join('/')}
    css_includes = %w(cms_master jquery-ui).collect{|f| ['cms', f].join('/')}
    
    
    ActionView::Helpers::AssetTagHelper.register_javascript_expansion :cms => js_includes
    ActionView::Helpers::AssetTagHelper.register_stylesheet_expansion :cms => css_includes
  end

end
