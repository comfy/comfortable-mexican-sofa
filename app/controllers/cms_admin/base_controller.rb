class CmsAdmin::BaseController < ApplicationController
  before_filter :register_asset_expansions

  layout 'cms_admin'

protected
  
  def register_asset_expansions
    js_includes =   [ 'jquery', 'jquery-ui', 'rails', 'cms',
                      'tiny_mce/jquery.tinymce', 'tiny_mce/tiny_mce',
                      'codemirror/codemirror', 'plupload/plupload.full.min',
                      'rteditor', 'syntax_highlighter', 'uploader' ].collect{|f| ['cms', f].join('/')}
    
    css_includes =  ['cms_master', 'jquery-ui'].collect{|f| ['cms', f].join('/')}
    
    ActionView::Helpers::AssetTagHelper.register_javascript_expansion :cms => js_includes
    ActionView::Helpers::AssetTagHelper.register_stylesheet_expansion :cms => css_includes
  end

end
