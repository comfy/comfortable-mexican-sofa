# frozen_string_literal: true

require_relative 'mixins/file_content'

# This is like the the file_link tag, but specifically for images
# Identify the image by its label {{ cms:image label }}
#
# `class`   - any html classes that you want on the image tag. For example "class1 class2"
#
# - variant_attrs are not functional, perhaps due to some change in ImageMagick
# - Simply use a class in your CSS / SASS to style your image display
# `label`   - attach label attribute to link or image tag
# `resize`  - imagemagick option. For example: "100x50>"
# `gravity` - imagemagick option. For example: "center"
# `crop`    - imagemagick option. For example: "100x50+0+0"

class ComfortableMediaSurfer::Content::Tags::Image < ComfortableMediaSurfer::Content::Tag
  include ComfortableMediaSurfer::Content::Tags::Mixins::FileContent

  attr_reader :identifier, :as, :variant_attrs

  def initialize(context:, params: [], source: nil)
    super

    options = params.extract_options!
    @identifier     = params[0]
    @as             = 'image'
    @class          = options['class']
    @variant_attrs  = options.slice('resize', 'gravity', 'crop') # broken for ImageMagick

    return if @identifier.present?

    raise Error, 'Missing identifier label for image tag'
  end

  # @return [Comfy::Cms::File]
  def file_record
    @file_record ||= context.site.files.detect { |f| f.label == identifier }
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
  :image, ComfortableMediaSurfer::Content::Tags::Image
)
