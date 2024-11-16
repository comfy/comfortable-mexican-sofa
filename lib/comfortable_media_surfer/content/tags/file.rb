# frozen_string_literal: true

require_relative 'mixins/file_content'

# File tag allows attaching of file to the page. This controls how files are
# uploaded and then displayed on the page. Example tag:
#   {{ cms:file identifier, as: link, label: "My File" }}
#
# `as`      - url (default) | link | image - render out link or image tag
# `label`   - attach label attribute to link or image tag
# `resize`  - imagemagic option. For example: "100x50>"
# `gravity` - imagemagic option. For example: "center"
# `crop`    - imagemagic option. For example: "100x50+0+0"
# `class`   - any html classes that you want on the result link or image tag. For example "class1 class2"
#
class ComfortableMediaSurfer::Content::Tags::File < ComfortableMediaSurfer::Content::Tags::Fragment
  include ComfortableMediaSurfer::Content::Tags::Mixins::FileContent

  # @type ["url", "link", "image"]
  attr_reader :as

  # @type [{String => String}]
  attr_reader :variant_attrs

  # @param (see ComfortableMediaSurfer::Content::Tag#initialize)
  def initialize(context:, params: [], source: nil)
    super
    @as             = options['as'] || 'url'
    @label          = options['label']
    @class          = options['class']
    @variant_attrs  = options.slice('resize', 'gravity', 'crop')
  end

  def form_field(object_name, view, index)
    name    = "#{object_name}[fragments_attributes][#{index}][files]"
    input   = view.send(:file_field_tag, name, id: form_field_id, class: 'form-control')

    attachments_partial =
      if fragment.attachments
        view.render(
          partial: 'comfy/admin/cms/fragments/form_fragment_attachments',
          locals: {
            object_name: object_name,
            index: index,
            attachments: fragment.attachments,
            fragment_id: identifier,
            multiple: false
          }
        )
      end

    yield view.safe_join([input, attachments_partial], '')
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

ComfortableMediaSurfer::Content::Renderer.register_tag(
  :file, ComfortableMediaSurfer::Content::Tags::File
)
