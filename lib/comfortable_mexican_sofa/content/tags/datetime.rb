# frozen_string_literal: true

# Tag for text content that is going to be rendered using text input with datetime widget
#   {{ cms:datetime identifier }}
#
class ComfortableMexicanSofa::Content::Tag::Datetime < ComfortableMexicanSofa::Content::Tag::Fragment

  def content
    fragment.datetime
  end

  def form_field(object_name, view, index)
    name    = "#{object_name}[fragments_attributes][#{index}][datetime]"
    options = { id: form_field_id, class: "form-control", data: { "cms-datetime" => true } }
    value   = content.present? ? content.to_s(:db) : ""
    input   = view.send(:text_field_tag, name, value, options)

    yield input
  end

end

ComfortableMexicanSofa::Content::Renderer.register_tag(
  :datetime, ComfortableMexicanSofa::Content::Tag::Datetime
)
