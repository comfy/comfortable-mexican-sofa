# frozen_string_literal: true

# Same tag as File, only it handles multiple attachments.
# Generally not a bad idea to handle rendering of this in a partial/helper.
# Example tag:
#   {{ cms:files identifier }}
#
class ComfortableMediaSurfer::Content::Tags::Files < ComfortableMediaSurfer::Content::Tags::File
  def content
    return '' if fragment.attachments.blank?

    fragment.attachments.collect do |attachment|
      super(file: attachment, label: attachment.filename)
    end.join(' ')
  end

  def form_field(object_name, view, index)
    name    = "#{object_name}[fragments_attributes][#{index}][files][]"
    input   = view.send(:file_field_tag, name, id: form_field_id, multiple: true, class: 'form-control')

    attachments_partial =
      if fragment.attachments
        view.render(
          partial: 'comfy/admin/cms/fragments/form_fragment_attachments',
          locals: {
            object_name: object_name,
            index: index,
            attachments: fragment.attachments,
            fragment_id: identifier,
            multiple: true
          }
        )
      end

    yield view.safe_join([input, attachments_partial], '')
  end
end

ComfortableMediaSurfer::Content::Renderer.register_tag(
  :files, ComfortableMediaSurfer::Content::Tags::Files
)
