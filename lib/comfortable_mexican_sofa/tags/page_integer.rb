class ComfortableMexicanSofa::Tag::PageInteger
  include ComfortableMexicanSofa::Tag
  
  def self.regex_tag_signature(identifier = nil)
    identifier ||= IDENTIFIER_REGEX
    /\{\{\s*cms:page:(#{identifier}):integer\s*\}\}/
  end
  
  def content(include_edit_tags = false)
    block.content
  end
  
end