module CmsHelper
  
  def cms_form_for(record_or_name_or_array, *args, &proc)
    options = args.extract_options!
    form_for(record_or_name_or_array, *(args << options.merge(:builder => CmsFormBuilder)), &proc)
  end
  
  # Helper method for all block tags. You can define your own method based
  # on tag type. Example:
  #   tag.type = CmsTag::MyAwesomeTag
  #   def my_awesome_tag ... end
  def cms_tag_field(tag, *args)
    tag_method = tag.type.split('::').last.underscore.downcase
    return send(tag_method, block) if self.respond_to? tag_method
    
    form_method = case tag
    when CmsTag::PageText
      :text_area_tag
    when CmsTag::PageString
      :text_field_tag
    when CmsTag::PageInteger
      :number_field_tag
    end
    
    %(
      <div class='form_element #{tag_method}_element'>
        <div class='label'>#{tag.label.to_s.titleize}</div>
        <div class='value'>
          #{send(form_method, 'cms_page[cms_blocks_attributes][][content]', tag.content)}
          #{hidden_field_tag('cms_page[cms_blocks_attributes][][label]', tag.label)}
          #{hidden_field_tag('cms_page[cms_blocks_attributes][][type]', tag.type)}
          #{hidden_field_tag('cms_page[cms_blocks_attributes][][id]', tag.id) unless tag.new_record?}
        </div>
      </div>
    ).html_safe if form_method
  end
  
end
