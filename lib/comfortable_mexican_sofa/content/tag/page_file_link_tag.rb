# frozen_string_literal: true

# This tag allows you to link page-level files from within the page content.
#
# E.g. if your layout has:
#
#   {{ cms:file graphic, render: false }}
#   {{ cms:files attachments, render: false }}
#
# You can link to the files from an individual page (or snippet rendered in
# the context of the page) like so:
#
#   {{ cms:page_file_link graphic }}
#   {{ cms:page_file_link attachments, filename: "cat.jpg" }}
#
# `as`              - url (default) | link | image - render out link or image tag
# `label`           - attach label attribute to link or image tag
# `class`           - any html classes that you want on the resulting link or image tag
# `filename`        - if you need to pull a single file from the collection (if cms:file tag was used)
# `resize_to_limit` - image_processing variant option. Value is dimensions like: "100x50"
# `resize_to_fit`   - same
# `resize_to_fill`  - same
# `resize_and_pad`  - same
#
class ComfortableMexicanSofa::Content::Tag::PageFileLinkTag < ComfortableMexicanSofa::Content::Tag
  include ComfortableMexicanSofa::Content::Tag::FileContentMixin

  attr_reader :identifier

  # This class does not inherit from the FragmentTag, so we need to copy some things
  def initialize(context:, params: [], source: nil)
    super

    @identifier = params[0]

    if @identifier.blank?
      raise Error, "Missing identifier for tag: #{source}"
    end
  end

  def fragment
    @fragment ||= context.fragments.detect { |f| f.identifier == identifier }
  end
end

ComfortableMexicanSofa::Content::Renderer.register_tag(
  :page_file_link, ComfortableMexicanSofa::Content::Tag::PageFileLinkTag
)
