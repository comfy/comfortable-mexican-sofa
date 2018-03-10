# frozen_string_literal: true

# Tag for boolean content that is going to be rendered using checkbox
#   {{ cms:checkbox identifier }}
#
class ComfortableMexicanSofa::Content::Tag::Checkbox < ComfortableMexicanSofa::Content::Tag::Fragment

  def content
    fragment.boolean
  end

  def form_field(object_name, view, index)
    name = "#{object_name}[fragments_attributes][#{index}][boolean]"

    input = view.content_tag(:div, class: "form-check mt-2") do
      view.concat view.hidden_field_tag(name, "0", id: nil)

      options = { id: form_field_id, class: "form-check-input position-static" }
      view.concat view.check_box_tag(name, "1", content.present?, options)
    end

    yield input
  end

end

ComfortableMexicanSofa::Content::Renderer.register_tag(
  :checkbox, ComfortableMexicanSofa::Content::Tag::Checkbox
)
