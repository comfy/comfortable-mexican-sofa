# File tag allows attaching of file to the page. This controls how files are
# uploaded and then displayed on the page. Example tag:
#   {{cms:file identifier, multiple: true, partial: "path/to/partial"}}
#
# `partial`   - path - use partial to render out files
# `render`    - true (default) | false - if you want to render out files manually
# `as`        - link (default) | image - render out link or image tag. Note: partial will clobber this
# `label`     - attach label attribute to link or image tag
# `size`      - imagemagic resize string. For example: "100x50>"
#
class ComfortableMexicanSofa::Content::Tag::File < ComfortableMexicanSofa::Content::Tag::Fragment

  def initialize(context, params_string)
    super
  end

  def form_field(view, index, &block)
    name    = "page[fragments_attributes][#{index}][files]"
    input   = view.send(:file_field_tag, name, {id: nil})

    attachments_partial = if fragment.attachments
      view.render(
        partial:  "comfy/admin/cms/files/fragment_attachments",
        object:   fragment.attachments
      )
    end

    yield [input, attachments_partial].join.html_safe
  end
end

ComfortableMexicanSofa::Content::Renderer.register_tag(
  :file, ComfortableMexicanSofa::Content::Tag::File
)
