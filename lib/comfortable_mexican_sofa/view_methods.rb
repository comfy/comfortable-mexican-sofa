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
end

ActionView::Base.send :include, ComfortableMexicanSofa::ViewMethods

ActionView::Helpers::AssetTagHelper.register_javascript_expansion :cms => [
  'comfortable_mexican_sofa/jquery',
  'comfortable_mexican_sofa/jquery-ui',
  'comfortable_mexican_sofa/rails',
  'comfortable_mexican_sofa/cms',
  'comfortable_mexican_sofa/plupload/plupload.full.min',
  'comfortable_mexican_sofa/uploader'
]
ActionView::Helpers::AssetTagHelper.register_stylesheet_expansion :cms => [
  'comfortable_mexican_sofa/reset',
  'comfortable_mexican_sofa/structure',
  'comfortable_mexican_sofa/typography'
]