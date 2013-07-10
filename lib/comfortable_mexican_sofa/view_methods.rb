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
    page         = Cms::Page.new(:site => cms_site)
    page_content = Cms::PageContent.new(:page => page)
    render :inline => ComfortableMexicanSofa::Tag.process_content(page_content, snippet.content)
  end
  
  # Content of a page block. This is how you get content from page:field
  # Example:
  #   cms_page_content(:left_column, CmsPage.first)
  #   cms_page_content(:left_column) # if @cms_page is present
  def cms_page_content(identifier, page = nil, variation = nil)
    return '' unless page ||= @cms_page
    return '' unless block = page.page_content(variation).blocks.find_by_identifier(identifier)
    # If block is a page_file(s) we will return objects instead of attempting
    # to render them out
    case block.tag
    when ComfortableMexicanSofa::Tag::PageFile
      block.files.first
    when ComfortableMexicanSofa::Tag::PageFiles
      block.files
    else
      render :inline => ComfortableMexicanSofa::Tag.process_content(page.page_content(variation), block.content)
    end
  end
end

ActionView::Base.send :include, ComfortableMexicanSofa::ViewMethods
