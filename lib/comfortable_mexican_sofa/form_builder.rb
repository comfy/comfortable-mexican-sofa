class ComfortableMexicanSofa::FormBuilder < BootstrapForm::FormBuilder

  INPUT_NAME = "page[fragments_attributes]"

  def field(tag, index)
    content = send("field_#{tag.format}", tag, index)
    content << @template.hidden_field_tag(
      "#{INPUT_NAME}[#{index}][identifier]", tag.identifier, id: nil
    )
    content << @template.hidden_field_tag(
      "#{INPUT_NAME}[#{index}][format]", tag.format, id: nil
    )

    form_group label: {text: tag.identifier.titleize} do
      content.html_safe
    end
  end

private

  def field_wysiwyg(tag, index)
    options = {id: nil, data: {"cms-rich-text" => true}}
    @template.send(:text_area_tag, "#{INPUT_NAME}[#{index}][content]", tag.content, options)
  end

  def field_text(tag, index)
    options = {id: nil, class: "form-control"}
    @template.send(:text_field_tag, "#{INPUT_NAME}[#{index}][content]", tag.content, options)
  end

  def field_textarea(tag, index)
    options = {id: nil, data: {"cms-cm-mode" => "text/html"}}
    @template.send(:text_area_tag, "#{INPUT_NAME}[#{index}][content]", tag.content, options)
  end

  def field_markdown(tag, index)
    options = {id: nil, data: {"cms-cm-mode" => "text/x-markdown"}}
    @template.send(:text_area_tag, "#{INPUT_NAME}[#{index}][content]", tag.content, options)
  end

  def field_datetime(tag, index)
    options = {id: nil, class: "form-control", data: {"cms-datetime" => true}}
    @template.send(:text_field_tag, "#{INPUT_NAME}[#{index}][content]", tag.content, options)
  end

  def field_date(tag, index)
    options = {id: nil, class: "form-control", data: {"cms-date" => true}}
    @template.send(:text_field_tag, "#{INPUT_NAME}[#{index}][content]", tag.content, options)
  end

  def field_number(tag, index)
    options = {id: nil, class: "form-control"}
    @template.send(:number_field_tag, "#{INPUT_NAME}[#{index}][content]", tag.content, options)
  end

  def field_boolean(tag, index)
    content = @template.hidden_field_tag("#{INPUT_NAME}[#{index}][content]", "", id: nil)
    content << @template.check_box_tag(
      "#{INPUT_NAME}[#{index}][content]", "1", tag.content.present?, id:  nil
    )
  end

  def field_file(tag, index)
    name = "#{INPUT_NAME}[#{index}][content]"
    options = {id: nil}
    if tag.multiple
      name << "[]"
      options.merge!(multiple: tag.multiple)
    end
    content = @template.send(:file_field_tag, name, options)
    if attachments = tag.content
      content << @template.render(partial: "comfy/admin/cms/files/fragment_attachments", object: attachments)
    end
    content
  end
end
