class ComfortableMexicanSofa::Tag::FieldInteger
  include ComfortableMexicanSofa::Tag
  
  def self.regex_tag_signature(label = nil)
    label ||= /[\w\-]+/
    /\{\{\s*cms:field:(#{label}):integer\s*\}\}/
  end
  
  def content
    block.content
  end
  
  def render
    ''
  end
  
end