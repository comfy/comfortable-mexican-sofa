class ComfortableMexicanSofa::Tag::Link
  include ComfortableMexicanSofa::Tag

  def self.regex_tag_signature(identifier = nil)
    identifier ||= /\/?[\.\p{Alnum}\p{Mark}_\-\/]*/
    /\{\{\s*cms:link:(#{identifier})\s*\}\}/
  end

  def content
    pages_table = Cms::Page.arel_table
    if p = page.site.pages.where(pages_table[:full_path].matches("%#{self.identifier.to_s}")).first
      p.url
    else
      ""
    end
  end
end
