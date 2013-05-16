class ComfortableMexicanSofa::Tag::PageText
  include ComfortableMexicanSofa::Tag

  def self.regex_tag_signature(identifier = nil)
    identifier ||= /\/?\p{Alnum}[\.\p{Alnum}\p{Mark}_\-\/]*/
    /\{\{\s*cms:link:(#{identifier})\s*\}\}/
  end

  def content
    pages = Cms::Page.arel_table
    if page = Cms::Page.where(pages[:full_path].matches("%#{self.identifier.to_s}")).first
      page.url
    else
      ""
    end
  end
end
