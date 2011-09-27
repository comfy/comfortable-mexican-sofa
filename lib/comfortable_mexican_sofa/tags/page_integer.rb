class ComfortableMexicanSofa::Tag::PageInteger
  include ComfortableMexicanSofa::Tag
  
  def self.regex_tag_signature(label = nil)
    label ||= /[\w\-]+/
    /\{\{\s*cms:page:(#{label}):integer\s*\}\}/
  end
  
  def content
    block.content
  end
  
end