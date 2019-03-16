# frozen_string_literal: true

require_relative "./mixins/file_content"

# This is how you link previously uploaded file to anywhere. Good example may be
# a header image you want to use on the layout level.
#   {{cms:file_link id, as: image}}
#
# `as`      - url (default) | link | image - how file gets rendered out
# `label`   - attach label attribute to link or image tag
# `resize`  - imagemagic option. For example: "100x50>"
# `gravity` - imagemagic option. For example: "center"
# `crop`    - imagemagic option. For example: "100x50+0+0"
# `class`   - any html classes that you want on the result link or image tag. For example "class1 class2"
#
class ComfortableMexicanSofa::Content::Tag::FileLink < ComfortableMexicanSofa::Content::Tag

  include ComfortableMexicanSofa::Content::Tag::Mixins::FileContent

  # @return [String] A {Comfy::Cms::Site#files} ID.
  attr_reader :identifier

  # @type ["url", "link", "image"]
  attr_reader :as

  # @type [{String => String}]
  attr_reader :variant_attrs

  def initialize(context:, params: [], source: nil)
    super

    options = params.extract_options!
    @identifier     = params[0]
    @as             = options["as"] || "url"
    @class          = options["class"]
    @variant_attrs  = options.slice("resize", "gravity", "crop")

    unless @identifier.present?
      raise Error, "Missing identifier for file link tag"
    end
  end

  # @return [Comfy::Cms::File]
  def file_record
    @file_record ||= context.site.files.detect { |f| f.id == identifier.to_i }
  end

  # @return [ActiveStorage::Blob]
  def file
    file_record&.attachment
  end

  # @return [String]
  def label
    return "" if file_record.nil?
    file_record.label.presence || file.filename.to_s
  end

end

ComfortableMexicanSofa::Content::Renderer.register_tag(
  :file_link, ComfortableMexicanSofa::Content::Tag::FileLink
)
