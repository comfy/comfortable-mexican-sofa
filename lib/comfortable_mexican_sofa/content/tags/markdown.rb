# Tag for text content that is going to be rendered using textarea with markdown
#   {{ cms:markdown identifier }}
#
class ComfortableMexicanSofa::Content::Tag::Markdown < ComfortableMexicanSofa::Content::Tag::Fragment

  def render
    self.renderable ? Kramdown::Document.new(self.content.to_s).to_html : ""
  end

  def form_field(object_name, view, index, &block)
    name    = "#{object_name}[fragments_attributes][#{index}][content]"
    options = {id: nil, data: {"cms-cm-mode" => "text/x-markdown"}}
    input   = view.send(:text_area_tag, name, self.content, options)

    yield input
  end
end

ComfortableMexicanSofa::Content::Renderer.register_tag(
  :markdown, ComfortableMexicanSofa::Content::Tag::Markdown
)
