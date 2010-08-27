class CmsAdmin::BaseController < ApplicationController
  before_filter :register_asset_expansions

  layout 'cms_admin'

protected
  
  def register_asset_expansions
    js_includes = ['jquery', 'jquery-ui', 'rails', 'cms'].collect{|f| ['cms', f].join('/')}
    js_includes += ['tiny_mce/jquery.tinymce', 'tiny_mce/tiny_mce', 'codemirror/codemirror', 'plupload/plupload.full.min' ].collect{|f| ['cms/3rdparty', f].join('/')}
    js_includes += ['rteditor', 'syntax_highlighter', 'uploader'].collect{|f| ['cms', f].join('/')}
    css_includes = %w(cms_master jquery-ui).collect{|f| ['cms', f].join('/')}
    
    
    ActionView::Helpers::AssetTagHelper.register_javascript_expansion :cms => js_includes
    ActionView::Helpers::AssetTagHelper.register_stylesheet_expansion :cms => css_includes
  end

end
