class ComfortableMexicanSofa::Tag::PageMarkdown
  include ComfortableMexicanSofa::Tag
  
  def self.regex_tag_signature(identifier = nil)
    identifier ||= IDENTIFIER_REGEX
    /\{\{\s*cms:page:(#{identifier}):markdown\s*\}\}/
  end
  
  def content(include_edit_tags = false)
    block.content
  end
  
  def render(include_edit_tags = false)
    Kramdown::Document.new(content.to_s).to_html
  end
end