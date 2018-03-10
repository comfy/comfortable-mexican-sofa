# frozen_string_literal: true

# Tag for text content that is going to be rendered using text input
#   {{ cms:text identifier }}
#
class ComfortableMexicanSofa::Content::Tag::Text < ComfortableMexicanSofa::Content::Tag::Fragment

  def form_field(object_name, view, index)
    name    = "#{object_name}[fragments_attributes][#{index}][content]"
    options = { id: form_field_id, class: "form-control" }
    input   = view.send(:text_field_tag, name, content, options)

    yield input
  end

end

ComfortableMexicanSofa::Content::Renderer.register_tag(
  :text, ComfortableMexicanSofa::Content::Tag::Text
)
