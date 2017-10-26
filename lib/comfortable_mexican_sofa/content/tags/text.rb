# Tag for text content that is going to be rendered using text input
#   {{ cms:text identifier }}
#
class ComfortableMexicanSofa::Content::Tag::Text < ComfortableMexicanSofa::Content::Tag::Fragment

  def form_field(view, index, &block)
    name    = "page[fragments_attributes][#{index}][content]"
    options = {id: nil, class: "form-control"}
    input   = view.send(:text_field_tag, name, self.content, options)

    yield input
  end
end

ComfortableMexicanSofa::Content::Renderer.register_tag(
  :text, ComfortableMexicanSofa::Content::Tag::Text
)
