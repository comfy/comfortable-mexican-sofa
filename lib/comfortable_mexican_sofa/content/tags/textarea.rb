# Tag for text content that is going to be rendered using textarea
#   {{ cms:textarea identifier }}
#
class ComfortableMexicanSofa::Content::Tag::TextArea < ComfortableMexicanSofa::Content::Tag::Fragment

  def form_field(view, index, &block)
    name    = "page[fragments_attributes][#{index}][content]"
    options = {id: nil, data: {"cms-cm-mode" => "text/html"}}
    input   = view.send(:text_area_tag, name, self.content, options)

    yield input
  end
end

ComfortableMexicanSofa::Content::Renderer.register_tag(
  :textarea, ComfortableMexicanSofa::Content::Tag::TextArea
)
