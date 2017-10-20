module Comfy
  module CmsHelper

    # Wrapper around ComfortableMexicanSofa::FormBuilder
    def comfy_form_for(record, options = {}, &block)
      options[:builder] = ComfortableMexicanSofa::FormBuilder
      options[:layout] ||= :horizontal
      bootstrap_form_for(record, options, &block)
    end

    # Injects some content somewhere inside cms admin area
    def cms_hook(name, options = {})
      ComfortableMexicanSofa::ViewHooks.render(name, self, options)
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

    # Raw content of a page fragment. This is how you get content from unrenderable
    # tags like {{cms:fragment meta, render: false}}
    # Example:
    #   cms_fragment_content(:left_column, CmsPage.first)
    #   cms_fragment_content(:left_column) # if @cms_page is present
    def cms_fragment_content(identifier, page = @cms_page)
      frag = page && page.fragments.find_by_identifier(identifier)
      return "" unless frag
      frag.content
    end

    # Same as cms_fragment_content but with cms tags expanded and rendered. Use
    # it only if you know you got more stuff in the fragment content other than
    # text because this is a potentially expensive call.
    def cms_fragment_render(identifier, page = @cms_page)
      node = page.fragment_nodes.detect{|n| n.identifier == identifier.to_s}
      return "" unless node
      render inline: page.render([node])
    end

    # Raw content of a snippet.
    # Example:
    #   cms_snippet_content(:my_snippet)
    def cms_snippet_content(identifier, cms_site = @cms_site)
      unless cms_site
        host, path = request.host_with_port.downcase, request.fullpath if respond_to?(:request) && request
        cms_site = Comfy::Cms::Site.find_site(host, path)
      end
      snippet = cms_site && cms_site.snippets.find_by_identifier(identifier)
      return "" unless snippet
      snippet.content
    end

    # Same as cms_snippet_content but cms tags will be expanded. Note that there
    # is no page context, so snippet cannot contain fragment tags.
    def cms_snippet_render(identifier, cms_site = @cms_site)
      content = cms_snippet_content(identifier, cms_site)
      r = ComfortableMexicanSofa::Content::Renderer.new(Comfy::Cms::Page.new)
      render inline: r.render(r.nodes(r.tokenize(content)))
    end
  end
end
