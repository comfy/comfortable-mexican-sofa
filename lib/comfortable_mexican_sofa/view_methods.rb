module ComfortableMexicanSofa::ViewMethods

  # Wrapper around ComfortableMexicanSofa::FormBuilder
  def comfy_form_for(record, options = {}, &proc)
    options[:builder] = ComfortableMexicanSofa::FormBuilder
    options[:type] ||= :horizontal
    formatted_form_for(record, options, &proc)
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
  def cms_snippet_content(identifier, cms_site = nil, &block)
    unless cms_site
      host, path = request.host.downcase, request.fullpath if respond_to?(:request) && request
      cms_site ||= (@cms_site || Cms::Site.find_site(host, path))
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
    
    return '' unless snippet
    render :inline => ComfortableMexicanSofa::Tag.process_content(cms_site.pages.build, ComfortableMexicanSofa::Tag.sanitize_irb(snippet.content))
  end

  # Content of a text based page block. This is the typical method for retrieving content from
  # page:field. Note: This method will be faster than the more generic cms_page_content.
  #
  # Example:
  #   cms_page_block_content(:left_column, CmsPage.first)
  #   cms_page_block_content(:left_column) if @cms_page is present
  def cms_page_block_content(identifier, page = nil)
    return '' unless page ||= @cms_page
    return '' unless block = page.blocks.find_by_identifier(identifier)

    ComfortableMexicanSofa::Tag.process_content(page, block.content)
  end

  # Fetch files from a page:field. Will return a list of files, regardless of how many files are present.
  # Note: This method will be faster than the more generic cms_page_content.
  #
  # Example:
  #   cms_page_block_content(:open_graph_image, CmsPage.first)
  #   cms_page_block_content(:attachments, CmsPage.first)
  def cms_page_files(identifier, page = nil)
    return nil unless page ||= @cms_page
    return nil unless block = page.blocks.find_by_identifier(identifier)

    block.files
  end

  # Content of a page block. This is how you get content from page:field
  # Example:
  #   cms_page_content(:left_column, CmsPage.first)
  #   cms_page_content(:left_column) # if @cms_page is present
  def cms_page_content(identifier, page = nil)
    return '' unless page ||= @cms_page
    return '' unless block = page.blocks.find_by_identifier(identifier)
    # If block is a page_file(s) we will return objects instead of attempting
    # to render them out
    case block.tag
    when ComfortableMexicanSofa::Tag::PageFile
      block.files.first
    when ComfortableMexicanSofa::Tag::PageFiles
      block.files
    else
      render :inline => ComfortableMexicanSofa::Tag.process_content(page, ComfortableMexicanSofa::Tag.sanitize_irb(block.content))
    end
  end
end

ActionView::Base.send :include, ComfortableMexicanSofa::ViewMethods
