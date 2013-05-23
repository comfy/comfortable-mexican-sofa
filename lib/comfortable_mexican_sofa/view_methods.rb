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

  def cms_layout_head
    if @cms_page
      render inline: @cms_page.layout.merged_head(@cms_page)
    end
  end
  
  # Content of a snippet. Example:
  #   cms_snippet_content(:my_snippet)
  def cms_snippet_content(identifier, cms_site = nil)
    unless cms_site
      host, path = request.host.downcase, request.fullpath if respond_to?(:request) && request
      cms_site ||= (@cms_site || Cms::Site.find_site(host, path))
    end
    return '' unless cms_site 
    case identifier
    when Cms::Snippet
      snippet = identifier
    else
      return '' unless snippet = cms_site.snippets.find_by_identifier(identifier)
    end
    render :inline => ComfortableMexicanSofa::Tag.process_content(cms_site.pages.build, snippet.content)
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
      render :inline => ComfortableMexicanSofa::Tag.process_content(page, block.content)
    end
  end
end

ActionView::Base.send :include, ComfortableMexicanSofa::ViewMethods
