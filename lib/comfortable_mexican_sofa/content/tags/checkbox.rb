# Tag for boolean content that is going to be rendered using checkbox
#   {{ cms:checkbox identifier }}
#
class ComfortableMexicanSofa::Content::Tag::Checkbox < ComfortableMexicanSofa::Content::Tag::Fragment

  def content
    fragment.boolean
  end

  def form_field(object_name, view, index, &block)
    name = "#{object_name}[fragments_attributes][#{index}][boolean]"
    checkbox_hidden = view.hidden_field_tag(name, "0", id: nil)
    checkbox_input  = view.check_box_tag(name, "1", content.present?, id: nil)

    yield [checkbox_hidden, checkbox_input].join.html_safe
  end
end

ComfortableMexicanSofa::Content::Renderer.register_tag(
  :checkbox, ComfortableMexicanSofa::Content::Tag::Checkbox
)
