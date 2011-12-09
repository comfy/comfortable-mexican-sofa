class ComfortableMexicanSofa::Tag::PageInteger
  include ComfortableMexicanSofa::Tag
  
  def self.regex_tag_signature(identifier = nil)
    identifier ||= /[\w\-]+/
    /\{\{\s*cms:page:(#{identifier}):integer\s*\}\}/
  end
  
  def content
    block.content
  end
  
end