class String
  # Converts string to something suitable to be used as an element id
  def idify
    self.strip.gsub(/\W/, '_').gsub(/\s|^_*|_*$/, '').squeeze('_')
  end
end

module CmsViewHelpers
  
  # Wrapper around CmsFormBuilder
  def cms_form_for(record_or_name_or_array, *args, &proc)
    options = args.extract_options!
    form_for(record_or_name_or_array, *(args << options.merge(:builder => CmsFormBuilder)), &proc)
  end
  
  # Rails 3.0 doesn't have this helper defined
  def datetime_field_tag(name, value = nil, options = {})
    text_field_tag(name, value, options.stringify_keys.update('type' => 'datetime'))
  end
end

ActionView::Base.send :include, CmsViewHelpers 