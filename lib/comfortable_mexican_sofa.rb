require File.expand_path('comfortable_mexican_sofa/cms_form_builder', File.dirname(__FILE__))
require File.expand_path('../app/models/cms_block', File.dirname(__FILE__))
require File.expand_path('comfortable_mexican_sofa/cms_tag', File.dirname(__FILE__))

Dir.glob(File.expand_path('comfortable_mexican_sofa/cms_tag/*.rb', File.dirname(__FILE__))).each do |tag| 
  require tag
end

module ComfortableMexicanSofa
  
  # TODO
  
end

js_includes =   [ 'jquery', 'jquery-ui', 'rails', 'cms',
                  'tiny_mce/jquery.tinymce', 'tiny_mce/tiny_mce',
                  'codemirror/codemirror', 'plupload/plupload.full.min',
                  'rteditor', 'syntax_highlighter', 'uploader' ].collect{|f| ['cms', f].join('/')}

css_includes =  ['cms_master', 'jquery-ui'].collect{|f| ['cms', f].join('/')}

ActionView::Helpers::AssetTagHelper.register_javascript_expansion :cms => js_includes
ActionView::Helpers::AssetTagHelper.register_stylesheet_expansion :cms => css_includes