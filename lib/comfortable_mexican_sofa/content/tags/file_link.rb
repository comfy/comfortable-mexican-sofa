# This is how you link previously uploaded file to anywhere. Good example may be
# a header image you want to use on the layout level.
#   {{cms:file_link id, as: image}}
#
# `as` - url (default) | link | image - how file gets rendered out
#
class ComfortableMexicanSofa::Content::Tag::FileLink < ComfortableMexicanSofa::Content::Tag

  attr_reader :identifier, :as, :label

  def initialize(context, params_string)
    super

    options = params.extract_options!
    @identifier = params[0]
    @as         = options["as"] || "url"

    unless @identifier.present?
      raise Error, "Missing identifier for file link tag"
    end
  end

  def file
    @file ||= context.site.files.detect{|f| f.id == self.identifier.to_i}
  end

  def content
    return "" unless file

    case @as
    when "link"
      "<a href='#{url_for(file.attachment)}' target='_blank'>#{label}</a>"
    when "image"
      "<img src='#{url_for(file.attachment)}' alt='#{label}'/>"
    else
      url_for(file.attachment)
    end
  end

protected

  def label
    @file.label.present?? @file.label : @file.attachment.filename
  end

  def url_for(attachment)
    ApplicationController.render(
      inline: "<%= url_for(@attachment) %>",
      assigns: {attachment: attachment}
    )
  end
end

ComfortableMexicanSofa::Content::Renderer.register_tag(
  :file_link, ComfortableMexicanSofa::Content::Tag::FileLink
)
