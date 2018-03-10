# frozen_string_literal: true

# Tag for text content that is going to be rendered using Redactor (default) in
# the admin area
#   {{ cms:wysiwyg identifier }}
#
#
class ComfortableMexicanSofa::Content::Tag::Wysiwyg < ComfortableMexicanSofa::Content::Tag::Fragment

  def form_field(object_name, view, index)
    name    = "#{object_name}[fragments_attributes][#{index}][content]"
    options = { id: form_field_id, data: { "cms-rich-text" => true } }
    input   = view.send(:text_area_tag, name, content, options)
    yield input
  end

end

ComfortableMexicanSofa::Content::Renderer.register_tag(
  :wysiwyg, ComfortableMexicanSofa::Content::Tag::Wysiwyg
)
