# frozen_string_literal: true

require_relative "./mixins/file_content"

# This tag allows you to link page-level files from within the page content.
#
# E.g. if your layout has:
#
#   {{ cms:file graphic, render: false }}
#   {{ cms:files attachments, redner: false }}
#
# You can link to the files from an individual page (or snippet rendered in
# the context of the page) like so:
#
#   {{ cms:page_file_link graphic }}
#   {{ cms:page_file_link attachments, filename: "cat.jpg" }}
#
# `as`      - url (default) | link | image - how file gets rendered out
# `label`   - attach label attribute to link or image tag
# `resize`  - imagemagick option. For example: "100x50>"
# `gravity` - imagemagick option. For example: "center"
# `crop`    - imagemagick option. For example: "100x50+0+0"
# `class`   - any html classes that you want on the result link or image tag. For example "class1 class2"
#
class ComfortableMexicanSofa::Content::Tag::PageFileLink < ComfortableMexicanSofa::Content::Tag

  include ComfortableMexicanSofa::Content::Tag::Mixins::FileContent

  # @return [String] A `cms:file(s)` identifier.
  attr_reader :identifier

  # @type ["url", "link", "image"]
  attr_reader :as

  # @type [{String => String}]
  attr_reader :variant_attrs

  # @return [String] Used to refer to a file in a {{ cms:files }} tag.
  attr_reader :filename

  # @param (see ComfortableMexicanSofa::Content::Tag#initialize)
  def initialize(context:, params: [], source: nil)
    super

    options = params.extract_options!
    @identifier     = params[0]
    @as             = options["as"] || "url"
    @class          = options["class"]
    @variant_attrs  = options.slice("resize", "gravity", "crop")
    @filename       = options["filename"]

    unless @identifier.present?
      raise Error, "Missing identifier for page file link tag"
    end
  end

  # @return [Comfy::Cms::Fragment]
  def fragment
    @fragment ||= context.fragments.detect { |f| f.identifier == identifier }
  end

  # @return [ActiveStorage::Blob]
  def file
    @file ||=
      if fragment.nil?
        nil
      elsif filename.nil?
        fragment.attachments.first
      else
        fragment.attachments.detect { |a| a.filename.to_s == filename }
      end
  end

  # @return [String]
  def label
    return if file.nil?
    file.filename.to_s
  end

end

ComfortableMexicanSofa::Content::Renderer.register_tag(
  :page_file_link, ComfortableMexicanSofa::Content::Tag::PageFileLink
)
