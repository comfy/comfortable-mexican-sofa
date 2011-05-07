module ComfortableMexicanSofa::ViewMethods
  # Wrapper around CmsFormBuilder
  def cms_form_for(record_or_name_or_array, *args, &proc)
    options = args.extract_options!
    form_for(record_or_name_or_array, *(args << options.merge(:builder => ComfortableMexicanSofa::FormBuilder)), &proc)
  end
  
  # Wrapper for <span>
  def span_tag(*args)
    content_tag(:span, *args)
  end
  
  # Rails 3.0 doesn't have this helper defined
  def datetime_field_tag(name, value = nil, options = {})
    text_field_tag(name, value, options.stringify_keys.update('type' => 'datetime'))
  end
  
  # Injects some content somewhere inside cms admin area
  def cms_hook(name, options = {})
    ComfortableMexicanSofa::ViewHooks.render(name, self, options)
  end
  
  # Content of a snippet. Example:
  #   cms_snippet_content(:my_snippet)
  def cms_snippet_content(snippet_slug, cms_site = nil)
    return '' unless cms_site ||= (@cms_site || Cms::Site.find_by_hostname!(request.host.downcase))
    return '' unless snippet = cms_site.snippets.find_by_slug(snippet_slug)
    ComfortableMexicanSofa::Tag.process_content(Cms::Page.new, snippet.content).html_safe
  end
  
  # Content of a page block. This is how you get content from page:field
  # Example:
  #   cms_page_content(:left_column, CmsPage.first)
  #   cms_page_content(:left_column) # if @cms_page is present
  def cms_page_content(block_label, page = nil)
    return '' unless page ||= @cms_page
    return '' unless block = page.blocks.find_by_label(block_label)
    ComfortableMexicanSofa::Tag.process_content(page, block.content).html_safe
  end
end

ActionView::Base.send :include, ComfortableMexicanSofa::ViewMethods

ActionView::Helpers::AssetTagHelper.register_javascript_expansion :cms => [
  'comfortable_mexican_sofa/jquery',
  'comfortable_mexican_sofa/jquery-ui/jquery-ui',
  'comfortable_mexican_sofa/rails',
  'comfortable_mexican_sofa/plupload/plupload.min',
  'comfortable_mexican_sofa/plupload/plupload.html5.min',
  'comfortable_mexican_sofa/codemirror/codemirror.js',
  'comfortable_mexican_sofa/cms'
]
ActionView::Helpers::AssetTagHelper.register_javascript_expansion :tiny_mce => [
  'comfortable_mexican_sofa/tiny_mce/tiny_mce',
  'comfortable_mexican_sofa/tiny_mce/jquery.tinymce'
]

ActionView::Helpers::AssetTagHelper.register_stylesheet_expansion :cms => [
  'comfortable_mexican_sofa/reset',
  'comfortable_mexican_sofa/structure',
  'comfortable_mexican_sofa/typography',
  'comfortable_mexican_sofa/form',
  'comfortable_mexican_sofa/content',
  '/javascripts/comfortable_mexican_sofa/jquery-ui/jquery-ui'
]