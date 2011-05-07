class ComfortableMexicanSofa::Tag::PageString
  include ComfortableMexicanSofa::Tag
  
  def self.regex_tag_signature(label = nil)
    label ||= /[\w\-]+/
    /\{\{\s*cms:page:(#{label}):string\s*\}\}/
  end
  
  def content=(value)
    block.content = value
  end
  
  def content
    block.content
  end
  
end