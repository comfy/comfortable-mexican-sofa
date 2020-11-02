#require 'app/helpers/comfy/cms_helper.rb'

# frozen_string_literal: true

# A mixin for tags that returns the file as their content.
module ComfortableMexicanSofa::Content::Tag::Mixins
  module FileContent
    def url_for_cms(blob)
      url_helpers = Rails.application.routes.url_helpers

      if Rails.env.test?
        if blob.is_a?(ActiveStorage::Variant)
          return url_helpers.rails_representation_path(blob, only_path: true)
        else
          return url_helpers.rails_blob_path(blob, only_path: true)
        end
      end

      if blob.is_a?(ActiveStorage::Variant)
        return url_helpers.rails_public_blob_url(blob.blob)
      end

      url_helpers.rails_public_blob_url(blob)
    end

    # @param [ActiveStorage::Blob] file
    # @param ["link", "image", "url"] as
    # @param [{String => String}] variant_attrs ImageMagick variant attributes
    # @param [String] label alt text for `as: "image"`, link text for `as: "link"`
    # @return [String]
    def content(file: self.file, as: self.as, variant_attrs: self.variant_attrs, label: self.label)
      return "" unless file

      attachment_url =
        if variant_attrs.present? && file.image?
          variant = file.variant(combine_options: variant_attrs)
          url_for_cms(variant)
        else
          url_for_cms(file)
        end

      case as
      when "link"
        "<a href='#{attachment_url}'#{html_class_attribute} target='_blank'>#{label}</a>"
      when "image"
        "<img src='#{attachment_url}'#{html_class_attribute} alt='#{label}'/>"
      else
        attachment_url
      end
    end

  private

    def html_class_attribute
      return if @class.blank?
      " class='#{@class}'"
    end

  end
end
