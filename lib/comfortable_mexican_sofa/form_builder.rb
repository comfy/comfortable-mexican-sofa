class ComfortableMexicanSofa::FormBuilder < BootstrapForm::FormBuilder

  def field(record, tag, index)
    object_name = record.class.to_s.demodulize.underscore

    tag.form_field(object_name, @template, index) do |tag_input|
      name = "#{object_name}[fragments_attributes][#{index}][identifier]"
      identifer_input = @template.hidden_field_tag(name, tag.identifier, id: nil)

      name  = "#{object_name}[fragments_attributes][#{index}][tag]"
      value = tag.class.to_s.demodulize.underscore
      tag_name_input = @template.hidden_field_tag(name, value, id: nil)

      label = I18n.t("comfy.cms.content.tag.#{tag.identifier}", default: tag.identifier.titleize)
      renderable = tag.respond_to?(:renderable) ? tag.renderable : true

      form_group bootstrap: {label: { text: label, class: "renderable-#{renderable}" }} do
        [identifer_input, tag_name_input, tag_input].join.html_safe
      end
    end
  end

  # Wrapper for form action that is sticking to the bottom of the viewport
  def form_actions(&block)
    <<-HTML.strip_heredoc.html_safe
      <div class="form-actions row bg-light">
        <div class="col-lg-8 offset-lg-2">
          <div class="form-group row mb-0">
            <div class="col-sm-10 offset-sm-2">
              #{capture(&block)}
            </div>
          </div>
        </div>
      </div>
    HTML
  end

end
