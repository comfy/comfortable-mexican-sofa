class ComfortableMexicanSofa::Tag::PageText
  include ComfortableMexicanSofa::Tag
  
  def self.regex_tag_signature(identifier = nil)
    identifier ||= IDENTIFIER_REGEX
    /\{\{\s*cms:page:(#{identifier}):?(?:text)?\s*\}\}/
  end
  
  def content
    block.content
  end
  
end