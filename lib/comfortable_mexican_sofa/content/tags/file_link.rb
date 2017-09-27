# This is how you link previously uploaded file to anywhere. Good example may be
# a header image you want to use on the layout level.
#   {{cms:file_link identifier as: image}}
#
# `as`    - url (default) | link | image - how file gets rendered out
# `label` - text for the link or alt text for image
#
class ComfortableMexicanSofa::Content::Tag::FileLink < ComfortableMexicanSofa::Content::Tag

  attr_reader :identifier, :as, :label

  def initialize(context, params_string)
    super

    options = params.extract_options!
    @identifier = params[0]
    @as         = options["as"] || "url"
    @label      = options["label"] || @identifier

    unless @identifier.present?
      raise Error, "Missing identifier for file link tag"
    end
  end

  def file
    @file ||= context.site.files.detect{|f| f.file_file_name == self.identifier.to_s}
  end

  def content
    return "" unless file

    case @as
    when "link"
      "<a href='#{file.file.url}' target='_blank'>#{@label}</a>"
    when "image"
      "<img src='#{file.file.url}' alt='#{@label}' />"
    else
      file.file.url
    end
  end
end

ComfortableMexicanSofa::Content::Renderer.register_tag(
  :file_link, ComfortableMexicanSofa::Content::Tag::FileLink
)
