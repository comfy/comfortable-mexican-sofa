class ComfortableMexicanSofa::Tag::FieldDateTime
  include ComfortableMexicanSofa::Tag
  
  def self.regex_tag_signature(label = nil)
    label ||= /[\w\-]+/
    /\{\{\s*cms:field:(#{label}):datetime\s*\}\}/
  end
  
  def content
    block.content
  end
  
  def render
    ''
  end
  
end