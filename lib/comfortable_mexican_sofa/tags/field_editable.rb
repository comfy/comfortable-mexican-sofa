class ComfortableMexicanSofa::Tag::FieldEditable
  include ComfortableMexicanSofa::Tag
  
  def self.regex_tag_signature(identifier = nil)
    identifier ||= IDENTIFIER_REGEX
    /\{\{\s*cms:field:(#{identifier}):?(?:editable)?\s*?\}\}/
  end
  
  def content
    block.content
  end
  
  def render
    ''
  end
  
end