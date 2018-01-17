# Same tag as File, only it handles multiple attachments.
# Generally not a bad idea to handle rendering of this in a partial/helper
#
class ComfortableMexicanSofa::Content::Tag::Files < ComfortableMexicanSofa::Content::Tag::File

  def initialize(context: nil, params: [], source: nil)
    super
  end

  def content
    return "" if fragment.attachments.blank?

    fragment.attachments.collect do |attachment|
      super(attachment)
    end.join(" ")
  end

  def form_field(object_name, view, index)
    name    = "#{object_name}[fragments_attributes][#{index}][files][]"
    input   = view.send(:file_field_tag, name, id: nil, multiple: true)

    attachments_partial =
      if fragment.attachments
        view.render(
          partial: "comfy/admin/cms/fragments/form_fragment_attachments",
          locals: {
            object_name:  object_name,
            index:        index,
            attachments:  fragment.attachments
          }
        )
      end

    yield [input, attachments_partial].join.html_safe
  end

end

ComfortableMexicanSofa::Content::Renderer.register_tag(
  :files, ComfortableMexicanSofa::Content::Tag::Files
)
