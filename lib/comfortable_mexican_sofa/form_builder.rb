class ComfortableMexicanSofa::FormBuilder < BootstrapForm::FormBuilder

  def default_label_col
    "col-sm-2 text-lg-right"
  end

  def field(record, tag, index)
    object_name = record.class.to_s.demodulize.underscore

    tag.form_field(object_name, @template, index) do |tag_input|

      name = "#{object_name}[fragments_attributes][#{index}][identifier]"
      identifer_input = @template.hidden_field_tag(name, tag.identifier, id: nil)

      name  = "#{object_name}[fragments_attributes][#{index}][tag]"
      value = tag.class.to_s.demodulize.underscore
      tag_name_input = @template.hidden_field_tag(name, value, id: nil)

      form_group label: {text: tag.identifier.titleize} do
        [identifer_input, tag_name_input, tag_input].join.html_safe
      end
    end
  end

  # Wrapper for form action that is sticking to the bottom of the viewport
  def form_actions(&block)
    <<~HTML.html_safe
      <div class="form-actions bg-light">
        <div class="row">
          <div class="col-lg-2"></div>
          <div class="col-lg-8">
            <div class="row">
              <div class="col-sm-2"></div>
              <div class="col-sm-10">
                #{capture(&block)}
              </div>
            </div>
          </div>
        </div>
      </div>
    HTML
  end
end
