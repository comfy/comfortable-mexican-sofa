class ComfortableMexicanSofa::FormBuilder < BootstrapForm::FormBuilder

  def field(tag, index)
    tag.form_field(@template, index) do |tag_input|

      name = "page[fragments_attributes][#{index}][identifier]"
      identifer_input = @template.hidden_field_tag(name, tag.identifier, id: nil)

      name  = "page[fragments_attributes][#{index}][tag]"
      value = tag.class.to_s.demodulize.underscore
      tag_name_input = @template.hidden_field_tag(name, value, id: nil)

      form_group label: {text: tag.identifier.titleize} do
        [identifer_input, tag_name_input, tag_input].join.html_safe
      end
    end
  end
end
