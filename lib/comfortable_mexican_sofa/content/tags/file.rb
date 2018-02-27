# frozen_string_literal: true

require_relative "file_content.rb"

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

  include ComfortableMexicanSofa::Content::Tag::FileContent
  include ActionView::Helpers::OutputSafetyHelper

  # @type ["url", "link", "image"]
  attr_reader :as

  # @type [{String => String}]
  attr_reader :variant_attrs

  # @param (see ComfortableMexicanSofa::Content::Tag#initialize)
  def initialize(context:, params: [], source: nil)
    super
    @as             = options["as"] || "url"
    @label          = options["label"]
    @variant_attrs  = options.slice("resize", "gravity", "crop")
  end

  def form_field(object_name, view, index)
    name    = "#{object_name}[fragments_attributes][#{index}][files]"
    input   = view.send(:file_field_tag, name, id: nil, class: "form-control")

    attachments_partial =
      if fragment.attachments
        view.render(
          partial: "comfy/admin/cms/fragments/form_fragment_attachments",
          locals: {
            object_name:  object_name,
            index:        index,
            attachments:  fragment.attachments,
            fragment_id: identifier,
            multiple:    false
          }
        )
      end

    yield safe_join([input, attachments_partial], "")
  end

protected

  # @return [ActiveStorage::Blob]
  def file
    fragment.attachments.first
  end

  # @return [String]
  def label
    @label || file&.filename
  end

end

ComfortableMexicanSofa::Content::Renderer.register_tag(
  :file, ComfortableMexicanSofa::Content::Tag::File
)
