# frozen_string_literal: true

# This is how you link previously uploaded file to anywhere. Good example may be
# a header image you want to use on the layout level. Options are the same as
# for {{ cms:page_file_link }}
#
#   {{ cms:site_file_link filename, as: image }}
#
class ComfortableMexicanSofa::Content::Tag::SiteFileLinkTag < ComfortableMexicanSofa::Content::Tag

  include ComfortableMexicanSofa::Content::Tag::FileContentMixin

  # This class does not inherit from the FragmentTag, so we need to copy some things
  def initialize(context:, params: [], source: nil)
    super

    @filename = params[0]

    unless @filename.present?
      raise Error, "Missing filename for tag: #{source}"
    end
  end

  # We only have one attachment and it's coming from Comfy::Cms::File
  def attachments
    file = context.site.files.detect { |f| f.attachment.filename.to_s == filename }
    return [] unless file

    Array.wrap(file.attachment)
  end
end

ComfortableMexicanSofa::Content::Renderer.register_tag(
  :site_file_link, ComfortableMexicanSofa::Content::Tag::SiteFileLinkTag
)
