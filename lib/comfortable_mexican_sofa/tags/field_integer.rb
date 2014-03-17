class ComfortableMexicanSofa::Tag::FieldInteger
  include ComfortableMexicanSofa::Tag
  
  def self.regex_tag_signature(identifier = nil)
    identifier ||= IDENTIFIER_REGEX
    /\{\{\s*cms:field:(#{identifier}):integer\s*\}\}/
  end
  
  def content(include_edit_tags = false)
    block.content
  end
  
  def render(include_edit_tags = false)
    ''
  end
  
end