# frozen_string_literal: true

module Comfy
  module Admin
    module CmsHelper

      # Wrapper around ComfortableMexicanSofa::FormBuilder
      def comfy_form_with(**options, &block)
        form_options = options.merge(builder: ComfortableMexicanSofa::FormBuilder)
        form_options[:bootstrap]  = { layout: :horizontal }
        form_options[:local]      = true
        bootstrap_form_with(**form_options, &block)
      end

      def comfy_admin_partial(path, params = {})
        render path, params
      rescue ActionView::MissingTemplate
        if ComfortableMexicanSofa.config.reveal_cms_partials
          content_tag(:div, class: "comfy-admin-partial") do
            path
          end
        end
      end

      # Injects some content somewhere inside cms admin area
      def cms_hook(name, options = {})
        ComfortableMexicanSofa::ViewHooks.render(name, self, options)
      end

      # @param [String] fragment_id
      # @param [ActiveStorage::Blob] attachment
      # @param [Boolean] multiple
      # @return [String] {{ cms:page_file_link #{fragment_id}, ... }}
      def cms_page_file_link_tag(fragment_id:, attachment:, multiple:)
        [
          "{{ cms:page_file_link #{fragment_id}",
          (", filename: \"#{attachment.filename}\"" if multiple),
          (", as: image" if attachment.image?),
          " }}"
        ].compact.join
      end

    end
  end
end
