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

      if variant_attrs.except("class").present? && file.image?
        file = file.variant(combine_options: variant_attrs)
      end

      url = rails_blob_path(file.blob)

      case as
      when "link"
        "<a href='#{url}' target='_blank'#{html_class}>#{label}</a>"
      when "image"
        "<img src='#{url}' alt='#{label}'#{html_class}/>"
      else
        url
      end
    end

    def html_class
      variant_attrs["class"].blank? ? "" : " class='#{variant_attrs['class']}'"
    end

    # @param [ActiveStorage::Blob]
    # @return [String]
    def rails_blob_path(blob)
      Rails.application.routes.url_helpers.rails_blob_path(blob, only_path: true)
    end

  end
end
