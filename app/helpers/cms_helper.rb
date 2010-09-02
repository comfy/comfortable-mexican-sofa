module CmsHelper
  
  def cms_form_for(record_or_name_or_array, *args, &proc)
    options = args.extract_options!
    form_for(record_or_name_or_array, *(args << options.merge(:builder => CmsFormBuilder)), &proc)
  end
  
  # Helper method for all block tags. You can define your own method based
  # on tag type. Example:
  #   tag.type = CmsTag::MyAwesomeTag
  #   def my_awesome_tag ... end
  def cms_block_field(block, *args)
    block_method = block.type.split('::').last.underscore.downcase
    return send(block_method, block) if self.respond_to? block_method
    
    form_method = case block
    when CmsTag::PageText
      :text_area_tag
    when CmsTag::PageString
      :text_field_tag
    when CmsTag::PageInteger
      :number_field_tag
    end
    
    %(
      <div class='form_element #{block_method}_element'>
        <div class='label'>#{block.label.to_s.titleize}</div>
        <div class='value'>
          #{send(form_method, 'cms_page[cms_blocks_attributes][][content]', block.content)}
          #{hidden_field_tag('cms_page[cms_blocks_attributes][][label]', block.label)}
          #{hidden_field_tag('cms_page[cms_blocks_attributes][][type]', block.type)}
        </div>
      </div>
    ).html_safe
  end
  
end
