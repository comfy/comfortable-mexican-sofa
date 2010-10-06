[ 'comfortable_mexican_sofa/cms_rails_extensions',
  'comfortable_mexican_sofa/cms_form_builder',
  'comfortable_mexican_sofa/cms_acts_as_tree',
  '../app/models/cms_block',
  '../app/models/cms_snippet',
  'comfortable_mexican_sofa/cms_tag' 
].each do |path|
  require File.expand_path(path, File.dirname(__FILE__))
end

Dir.glob(File.expand_path('comfortable_mexican_sofa/cms_tag/*.rb', File.dirname(__FILE__))).each do |tag_path| 
  require tag_path
end

ActionView::Helpers::AssetTagHelper.register_javascript_expansion :cms => [
  'comfortable_mexican_sofa/jquery',
  'comfortable_mexican_sofa/jquery-ui',
  'comfortable_mexican_sofa/rails',
  'comfortable_mexican_sofa/cms',
  'comfortable_mexican_sofa/tiny_mce/jquery.tinymce',
  'comfortable_mexican_sofa/tiny_mce/tiny_mce',
  'comfortable_mexican_sofa/codemirror/codemirror',
  'comfortable_mexican_sofa/plupload/plupload.full.min',
  'comfortable_mexican_sofa/uploader',
  'comfortable_mexican_sofa/rteditor',
  'comfortable_mexican_sofa/syntax_highlighter'
]
ActionView::Helpers::AssetTagHelper.register_stylesheet_expansion :cms => [
  'comfortable_mexican_sofa/reset',
  'comfortable_mexican_sofa/structure',
  'comfortable_mexican_sofa/typography',
  'comfortable_mexican_sofa/jquery-ui'
]

FILE_ICONS = Dir.glob(File.expand_path('public/images/cms/file_icons/*.png', Rails.root)).collect{|f| f.split('/').last.gsub('.png', '')}

module ComfortableMexicanSofa
  
  # TODO
  
end