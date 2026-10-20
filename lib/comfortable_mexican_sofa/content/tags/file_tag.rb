# frozen_string_literal: true

require_relative "./mixins/file_content"

# File tag allows attaching of file to the page. This controls how files are
# uploaded and then displayed on the page. Example tag:
#   {{ cms:file identifier, as: link, label: "My File" }}
#
# `as`              - url (default) | link | image - render out link or image tag
# `label`           - attach label attribute to link or image tag
# `class`           - any html classes that you want on the resulting link or image tag
# `resize_to_limit` - image_processing variant option. Value is the dimension like: "100x50"
# `resize_to_fit`   - same
# `resize_to_fill`  - same
# `resize_and_pad`  - same
#
class ComfortableMexicanSofa::Content::FileTag < ComfortableMexicanSofa::Content::FragmentTag

  include ComfortableMexicanSofa::Content::Tag::Mixins::FileContent

  MAX_VARIANT_DIMENSION = 2500

  # @type ["url", "link", "image"]
  attr_reader :as

  # @param (see ComfortableMexicanSofa::Content::Tag#initialize)
  def initialize(context:, params: [], source: nil)
    super

    @as    = options["as"] || "url"
    @label = options["label"]
    @class = options["class"]

    @variant_options = options.slice(
      "resize_to_limit",
      "resize_to_fit",
      "resize_to_fill",
      "resize_and_pad"
    )
  end

  # For simplicity sake, we only allow resizing and will convert
  def variant_options
    key, value = @variant_options&.first
    return {} unless key && value

    x, y = value.split("x").map(&:to_i)
    return {} unless x.positive? && y.positive?

    { key.to_sym => [x, y] }
  end

  def form_field(object_name, view, index)
    name    = "#{object_name}[fragments_attributes][#{index}][files]"
    input   = view.send(:file_field_tag, name, id: form_field_id, class: "form-control")

    attachments_partial =
      if fragment.attachments
        view.render(
          partial: "comfy/admin/cms/fragments/form_fragment_attachments",
          locals: {
            object_name:  object_name,
            index:        index,
            attachments:  fragment.attachments,
            fragment_id:  identifier,
            multiple:     false
          }
        )
      end

    yield view.safe_join([input, attachments_partial], "")
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
  :file, ComfortableMexicanSofa::Content::FileTag
)
