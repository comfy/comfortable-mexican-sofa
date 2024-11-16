# frozen_string_literal: true

# Tag for text content that is going to be rendered using textarea
#   {{ cms:textarea identifier }}
#

class ComfortableMediaSurfer::Content::Tags::Textarea < ComfortableMediaSurfer::Content::Tags::Fragment
  def form_field(object_name, view, index)
    name    = "#{object_name}[fragments_attributes][#{index}][content]"
    options = { id: form_field_id, data: { 'cms-cm-mode' => 'text/html' } }
    input   = view.send(:text_area_tag, name, content, options)

    yield input
  end
end

ComfortableMediaSurfer::Content::Renderer.register_tag(
  :textarea, ComfortableMediaSurfer::Content::Tags::Textarea
)
