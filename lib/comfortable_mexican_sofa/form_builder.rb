class ComfortableMexicanSofa::FormBuilder < BootstrapForm::FormBuilder

  INPUT_NAME = "page[fragments_attributes]"

  def field(fragment, index)
    content = send("field_#{fragment.format}", fragment, index)
    content << @template.hidden_field_tag(
      "#{INPUT_NAME}[#{index}][identifier]", fragment.identifier, id: nil
    )
    content << @template.hidden_field_tag(
      "#{INPUT_NAME}[#{index}][format]", fragment.format, id: nil
    )

    form_group label: {text: fragment.identifier.titleize} do
      content.html_safe
    end
  end

private

  def field_wysiwyg(frag, index)
    options = {id: nil, data: {"cms-rich-text" => true}}
    @template.send(:text_area_tag, "#{INPUT_NAME}[#{index}][content]", frag.content, options)
  end

  def field_text(frag, index)
    options = {id: nil, class: "form-control"}
    @template.send(:text_field_tag, "#{INPUT_NAME}[#{index}][content]", frag.content, options)
  end

  def field_textarea(frag, index)
    options = {id: nil, data: {"cms-cm-mode" => "text/html"}}
    @template.send(:text_area_tag, "#{INPUT_NAME}[#{index}][content]", frag.content, options)
  end

  def field_markdown(frag, index)
    options = {id: nil, data: {"cms-cm-mode" => "text/x-markdown"}}
    @template.send(:text_area_tag, "#{INPUT_NAME}[#{index}][content]", frag.content, options)
  end

  def field_datetime(frag, index)
    options = {id: nil, class: "form-control", data: {"cms-datetime" => true}}
    @template.send(:text_field_tag, "#{INPUT_NAME}[#{index}][content]", frag.content, options)
  end

  def field_date(frag, index)
    options = {id: nil, class: "form-control", data: {"cms-date" => true}}
    @template.send(:text_field_tag, "#{INPUT_NAME}[#{index}][content]", frag.content, options)
  end

  def field_number(frag, index)
    options = {id: nil, class: "form-control"}
    @template.send(:number_field_tag, "#{INPUT_NAME}[#{index}][content]", frag.content, options)
  end

  def field_checkbox(frag, index)
    content = @template.hidden_field_tag("#{INPUT_NAME}[#{index}][content]", "", id: nil)
    content << @template.check_box_tag(
      "#{INPUT_NAME}[#{index}][content]", "1", frag.content.present?, id:  nil
    )
  end

  def field_file(frag, index)
    name = "#{INPUT_NAME}[#{index}][content]"
    options = {id: nil}
    if frag.multiple
      name << "[]"
      options.merge!(multiple: frag.multiple)
    end
    content = @template.send(:file_field_tag, name, options)
    content << "TODO: File display partial"
  end
end
