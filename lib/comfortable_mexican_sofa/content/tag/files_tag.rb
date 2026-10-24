# frozen_string_literal: true

# File tag allows attaching of file to the page. This controls how files are
# uploaded and then displayed on the page. Example tag:
#   {{ cms:file identifier, as: link, label: "My File" }}
#
# `as`              - url (default) | link | image - render out link or image tag
# `label`           - attach label attribute to link or image tag
# `class`           - any html classes that you want on the resulting link or image tag
# `resize_to_limit` - image_processing variant option. Value is the dimension like: "100x50"
# `resize_to_fit`   - same
# `resize_to_fill`  - same
# `resize_and_pad`  - same
#
class ComfortableMexicanSofa::Content::Tag::FilesTag < ComfortableMexicanSofa::Content::FragmentTag

  include ComfortableMexicanSofa::Content::Tag::FileContentMixin

  attr_reader :as, :html_class

  # @param (see ComfortableMexicanSofa::Content::Tag#initialize)
  def initialize(context:, params: [], source: nil)
    super

    @as         = options["as"] || "url"
    @label      = options["label"]
    @html_class = options["class"]
  end

  def form_field(object_name, view, index)
    name  = "#{object_name}[fragments_attributes][#{index}][files]"
    input = view.send(:file_field_tag, name, id: form_field_id, multiple: true, class: "form-control")

    component = Comfy::Cms::FormFragmentFilesComponent.new(
      object_name: object_name, index: index, fragment: fragment
    )
    attachments = view.render(component)

    yield view.safe_join([input, attachments], "")
  end
end

ComfortableMexicanSofa::Content::Renderer.register_tag(
  :files, ComfortableMexicanSofa::Content::Tag::FilesTag
)
