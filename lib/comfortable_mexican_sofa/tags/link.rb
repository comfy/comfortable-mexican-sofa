class ComfortableMexicanSofa::Tag::Link
  include ComfortableMexicanSofa::Tag

  def self.regex_tag_signature(identifier = nil)
    identifier ||= /\/?[\.\p{Alnum}\p{Mark}_\-\/]*/
    /\{\{\s*cms:link:(#{identifier})\s*\}\}/
  end

  def content(include_edit_tags = false)
    pages_table = Cms::Page.arel_table
    # Find pages that match
    pages = page.site.pages.where(pages_table[:full_path].matches("%#{self.identifier.to_s}"))
    # Find the one with the shortest full_path (more likely to be a direct
    # match). TODO: Order the results in the SQL query instead?
    if pages.length > 0
      pages.to_a.sort{|a, b| a.full_path.length <=> b.full_path.length }.first.url
    else
      ""
    end
  end
end
