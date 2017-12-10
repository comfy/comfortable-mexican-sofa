# This is how you link previously uploaded file to anywhere. Good example may be
# a header image you want to use on the layout level.
#   {{cms:file_link id, as: image}}
#
# `as`      - url (default) | link | image - how file gets rendered out
# `label`   - attach label attribute to link or image tag
# `resize`  - imagemagic option. For example: "100x50>"
# `gravity` - imagemagic option. For example: "center"
# `crop`    - imagemagic option. For example: "100x50+0+0"
#
class ComfortableMexicanSofa::Content::Tag::FileLink < ComfortableMexicanSofa::Content::Tag

  attr_reader :identifier, :as, :variant_attrs

  def initialize(context, params_string)
    super

    options = params.extract_options!
    @identifier     = params[0]
    @as             = options["as"] || "url"
    @variant_attrs  = options.slice("resize", "gravity", "crop")

    unless @identifier.present?
      raise Error, "Missing identifier for file link tag"
    end
  end

  def file
    @file ||= context.site.files.detect { |f| f.id == identifier.to_i }
  end

  def label
    @file.label.present? ? @file.label : @file.attachment.filename
  end

  def content
    return "" unless file && file.attachment

    attachment = file.attachment
    if @variant_attrs.present? && attachment.image?
      attachment = attachment.variant(@variant_attrs)
    end

    case @as
    when "link"
      "<a href='#{url_for(attachment)}' target='_blank'>#{label}</a>"
    when "image"
      "<img src='#{url_for(attachment)}' alt='#{label}'/>"
    else
      url_for(attachment)
    end
  end

protected

  def url_for(attachment)
    ApplicationController.render(
      inline: "<%= url_for(@attachment) %>",
      assigns: { attachment: attachment }
    )
  end

end

ComfortableMexicanSofa::Content::Renderer.register_tag(
  :file_link, ComfortableMexicanSofa::Content::Tag::FileLink
)
