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
        filename  = ", filename: \"#{attachment.filename}\""  if multiple
        as        = ", as: image"                             if attachment.image?
        "{{ cms:page_file_link #{fragment_id}#{filename}#{as} }}"
      end

      # @param [Comfy::Cms::File] file
      # @return [String] {{ cms:file_link #{file.id}, ... }}
      def cms_file_link_tag(file)
        as = ", as: image" if file.attachment.image?
        "{{ cms:file_link #{file.id}#{as} }}"
      end

    end
  end
end
