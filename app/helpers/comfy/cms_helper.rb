module Comfy
  module CmsHelper

    # Wrapper around ComfortableMexicanSofa::FormBuilder
    def comfy_form_for(record, options = {}, &proc)
      options[:builder] = ComfortableMexicanSofa::FormBuilder
      options[:layout] ||= :horizontal
      bootstrap_form_for(record, options, &proc)
    end

    # Injects some content somewhere inside cms admin area
    def cms_hook(name, options = {})
      ComfortableMexicanSofa::ViewHooks.render(name, self, options)
    end

    # Content of a snippet. Examples:
    #   cms_snippet_content(:my_snippet)
    #   <%= cms_snippet_content(:my_snippet) do %>
    #     Default content can go here.
    #   <% end %>
    def cms_snippet_content(identifier, cms_site = @cms_site, &block)
      unless cms_site
        host, path = request.host_with_port.downcase, request.fullpath if respond_to?(:request) && request
        cms_site = Comfy::Cms::Site.find_site(host, path)
      end
      return '' unless cms_site

      snippet = cms_site.snippets.find_by_identifier(identifier)

      if !snippet && block_given?
        snippet = cms_site.snippets.create(
          :identifier => identifier,
          :label      => identifier.to_s.titleize,
          :content    => capture(&block)
        )
      end

      snippet ? snippet.content : ''
    end

    # Same as cms_snippet_content but cms tags will be expanded
    def cms_snippet_render(identifier, cms_site = @cms_site, &block)
      return '' unless cms_site
      content = cms_snippet_content(identifier, cms_site, &block)
      render :inline => ComfortableMexicanSofa::Tag.process_content(
        cms_site.pages.build, ComfortableMexicanSofa::Tag.sanitize_irb(content)
      )
    end

    # Content of a page block. This is how you get content from page:field
    # Example:
    #   cms_block_content(:left_column, CmsPage.first)
    #   cms_block_content(:left_column) # if @cms_page is present
    def cms_block_content(identifier, blockable = @cms_page)
      tag = blockable && (block = blockable.blocks.find_by_identifier(identifier)) && block.tag
      return '' unless tag
      tag.content
    end

    # For those times when we need to render content that shouldn't be renderable
    # Example: {{cms:field}} tags
    def cms_block_content_render(identifier, blockable = @cms_page)
      tag = blockable && (block = blockable.blocks.find_by_identifier(identifier)) && block.tag
      return '' unless tag
      render :inline => ComfortableMexicanSofa::Tag.process_content(blockable, tag.content)
    end

    # Same as cms_block_content but with cms tags expanded
    def cms_block_render(identifier, blockable = @cms_page)
      tag = blockable && (block = blockable.blocks.find_by_identifier(identifier)) && block.tag
      return '' unless tag
      render :inline => ComfortableMexicanSofa::Tag.process_content(blockable, tag.render)
    end

    # Wrapper to deal with Kaminari vs WillPaginate
    def comfy_paginate(collection)
      return unless collection
      if defined?(WillPaginate)
        will_paginate collection
      elsif defined?(Kaminari)
        paginate collection, :theme => 'comfy'
      end
    end
  end
end