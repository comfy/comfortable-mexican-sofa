class ComfortableMexicanSofa::Tag::FieldText
  include ComfortableMexicanSofa::Tag
  
  def self.regex_tag_signature(label = nil)
    label ||= /[\w\-]+/
    /\{\{\s*cms:field:(#{label}):?(?:text)?\s*?\}\}/
  end
  
  def content=(value)
    block.content = value
  end
  
  def content
    block.content
  end
  
  def render
    ''
  end
  
end