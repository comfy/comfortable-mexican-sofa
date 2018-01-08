# File tag allows attaching of file to the page. This controls how files are
# uploaded and then displayed on the page. Example tag:
#   {{cms:file identifier, as: link, label: "My File"}}
#
# `as`      - url (default) | link | image - render out link or image tag
# `label`   - attach label attribute to link or image tag
# `resize`  - imagemagic option. For example: "100x50>"
# `gravity` - imagemagic option. For example: "center"
# `crop`    - imagemagic option. For example: "100x50+0+0"
#
class ComfortableMexicanSofa::Content::Tag::File < ComfortableMexicanSofa::Content::Tag::Fragment

  attr_reader :as, :variant_attrs

  delegate :rails_blob_path, to: "Rails.application.routes.url_helpers"

  def initialize(context, params_string)
    super
    @as             = options["as"] || "url"
    @label          = options["label"]
    @variant_attrs  = options.slice("resize", "gravity", "crop")
  end

  def content(file = attachment)
    return "" unless file

    if @variant_attrs.present? && attachment.image?
      file = file.variant(@variant_attrs)
    end

    url = rails_blob_path(file, only_path: true)

    case @as
    when "link"
      "<a href='#{url}' target='_blank'>#{label}</a>"
    when "image"
      "<img src='#{url}' alt='#{label}'/>"
    else
      url
    end
  end

  def form_field(object_name, view, index)
    name    = "#{object_name}[fragments_attributes][#{index}][files]"
    input   = view.send(:file_field_tag, name, id: nil)

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

protected

  def attachment
    fragment.attachments.first
  end

  def label
    @label || attachment && attachment.filename
  end

end

ComfortableMexicanSofa::Content::Renderer.register_tag(
  :file, ComfortableMexicanSofa::Content::Tag::File
)
