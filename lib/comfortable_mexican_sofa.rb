%w(
  comfortable_mexican_sofa/cms_form_builder
  comfortable_mexican_sofa/cms_acts_as_tree
  ../app/models/cms_block
  comfortable_mexican_sofa/cms_tag
).each do |path|
  require File.expand_path(path, File.dirname(__FILE__))
end

Dir.glob(File.expand_path('comfortable_mexican_sofa/cms_tag/*.rb', File.dirname(__FILE__))).each do |tag_path| 
  require tag_path
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