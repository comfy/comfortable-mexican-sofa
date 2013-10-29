class ComfortableMexicanSofa::FormBuilder < FormattedForm::FormBuilder
  
  # -- Tag Field Fields -----------------------------------------------------
  def default_tag_field(tag, index, method = :text_field_tag, options = {})
    
    label     = tag.page.class.human_attribute_name(tag.identifier.to_s)
    css_class = tag.class.to_s.demodulize.underscore
    content   = ''
    
    case method
    when :file_field_tag
      input_params = {:id => nil}
      name = "page[blocks_attributes][#{index}][content]"
      
      if options.delete(:multiple)
        input_params.merge!(:multiple => true)
        name << '[]'
      end
      
      content << @template.send(method, name, input_params)
      content << @template.render(:partial => 'admin/cms/files/page_form', :object => tag.block)
    else
      content << @template.send(method, "page[blocks_attributes][#{index}][content]", tag.content, options)
    end
    content << @template.hidden_field_tag("page[blocks_attributes][#{index}][identifier]", tag.identifier, :id => nil)
    
    element(label, content.html_safe)
  end
  
  def field_date_time(tag, index)
    default_tag_field(tag, index, :text_field_tag, :data => {'cms-datetime' => true})
  end
  
  def field_integer(tag, index)
    default_tag_field(tag, index, :number_field_tag)
  end
  
  def field_string(tag, index)
    default_tag_field(tag, index)
  end
  
  def field_text(tag, index)
    default_tag_field(tag, index, :text_area_tag, :data => {'cms-cm-mode' => 'text/html'})
  end
  
  def field_rich_text(tag, index)
    default_tag_field(tag, index, :text_area_tag, :data => {'cms-rich-text' => true})
  end
  
  def page_date_time(tag, index)
    default_tag_field(tag, index, :text_field_tag, :data => {'cms-datetime' => true})
  end
  
  def page_integer(tag, index)
    default_tag_field(tag, index, :number_field_tag)
  end
  
  def page_string(tag, index)
    default_tag_field(tag, index)
  end
  
  def page_text(tag, index)
    default_tag_field(tag, index, :text_area_tag, :data => {'cms-cm-mode' => 'text/html'})
  end
  
  def page_rich_text(tag, index)
    default_tag_field(tag, index, :text_area_tag, :data => {'cms-rich-text' => true})
  end
  
  def page_file(tag, index)
    default_tag_field(tag, index, :file_field_tag)
  end
  
  def page_files(tag, index)
    default_tag_field(tag, index, :file_field_tag, :multiple => true)
  end
  
  def page_markdown(tag, index)
    default_tag_field(tag, index, :text_area_tag, :data => {'cms-cm-mode' => 'text/x-markdown'})
  end
  
  def collection(tag, index)
    options = [["---- Select #{tag.collection_class.titleize} ----", nil]] + 
      tag.collection_objects.collect do |m| 
        [m.send(tag.collection_title), m.send(tag.collection_identifier)]
      end
      
    content = @template.select_tag(
      "page[blocks_attributes][#{index}][content]",
      @template.options_for_select(options, :selected => tag.content),
      :id => nil
    )
    content << @template.hidden_field_tag("page[blocks_attributes][#{index}][identifier]", tag.identifier, :id => nil)
    element(tag.identifier.titleize, content, :class => tag.class.to_s.demodulize.underscore )
  end
  
end
