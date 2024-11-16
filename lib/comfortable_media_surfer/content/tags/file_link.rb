# frozen_string_literal: true

require_relative 'mixins/file_content'

# This is how you link previously uploaded file to anywhere. Good example may be
# a header image you want to use on the layout level.
#   {{cms:file_link id, as: image}}
#
# `as`      - url (default) | link | image - how file gets rendered out
# `class`   - any html classes that you want on the result link or image tag. For example "class1 class2"
#
# - variant_attrs are not functional, perhaps due to some change in ImageMagick
# - Simply use a class in your CSS / SASS to style your image display
# `label`   - attach label attribute to link or image tag
# `resize`  - imagemagick option. For example: "100x50>"
# `gravity` - imagemagick option. For example: "center"
# `crop`    - imagemagick option. For example: "100x50+0+0"
#
class ComfortableMediaSurfer::Content::Tags::FileLink < ComfortableMediaSurfer::Content::Tag
  include ComfortableMediaSurfer::Content::Tags::Mixins::FileContent

  attr_reader :identifier, :as, :variant_attrs

  def initialize(context:, params: [], source: nil)
    super

    options = params.extract_options!
    @identifier     = params[0]
    @as             = options['as'] || 'url'
    @class          = options['class']
    @variant_attrs  = options.slice('resize', 'gravity', 'crop') # broken for ImageMagick

    return if @identifier.present?

    raise Error, 'Missing identifier for file link tag'
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
    return '' if file_record.nil?

    file_record.label.presence || file.filename.to_s
  end
end

ComfortableMediaSurfer::Content::Renderer.register_tag(
  :file_link, ComfortableMediaSurfer::Content::Tags::FileLink
)
