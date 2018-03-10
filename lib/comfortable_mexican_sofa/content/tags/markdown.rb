# frozen_string_literal: true

# Tag for text content that is going to be rendered using textarea with markdown
#   {{ cms:markdown identifier }}
#
class ComfortableMexicanSofa::Content::Tag::Markdown < ComfortableMexicanSofa::Content::Tag::Fragment

  def render
    renderable ? Kramdown::Document.new(content.to_s).to_html : ""
  end

  def form_field(object_name, view, index)
    name    = "#{object_name}[fragments_attributes][#{index}][content]"
    options = { id: form_field_id, data: { "cms-cm-mode" => "text/x-markdown" } }
    input   = view.send(:text_area_tag, name, content, options)

    yield input
  end

end

ComfortableMexicanSofa::Content::Renderer.register_tag(
  :markdown, ComfortableMexicanSofa::Content::Tag::Markdown
)
