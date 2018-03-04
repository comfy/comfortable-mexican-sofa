# frozen_string_literal: true

# A mixin for tags that returns the file as their content.
module ComfortableMexicanSofa::Content::Tag::Mixins
  module FileContent

    # @param [ActiveStorage::Blob] file
    # @param ["link", "image", "url"] as
    # @param [{String => String}] variant_attrs ImageMagick variant attributes
    # @param [String] label alt text for `as: "image"`, link text for `as: "link"`
    # @return [String]
    def content(file: self.file, as: self.as, variant_attrs: self.variant_attrs, label: self.label)
      return "" unless file

      if variant_attrs.present? && attachment.image?
        file = file.variant(variant_attrs)
      end

      url = rails_blob_path(file)

      case as
      when "link"
        "<a href='#{url}' target='_blank'>#{label}</a>"
      when "image"
        "<img src='#{url}' alt='#{label}'/>"
      else
        url
      end
    end

    # @param [ActiveStorage::Blob]
    # @return [String]
    def rails_blob_path(blob)
      Rails.application.routes.url_helpers.rails_blob_path(blob, only_path: true)
    end

  end
end
