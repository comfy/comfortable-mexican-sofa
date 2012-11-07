class ComfortableMexicanSofa::Tag::FieldString
  include ComfortableMexicanSofa::Tag
  
  def self.regex_tag_signature(identifier = nil)
    identifier ||= IDENTIFIER_REGEX
    /\{\{\s*cms:field:(#{identifier}):?(?:string)?\s*\}\}/
  end
  
  def content
    block.content
  end
  
  def render
    ''
  end
  
end