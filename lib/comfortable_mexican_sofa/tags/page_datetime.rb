class ComfortableMexicanSofa::Tag::PageDateTime
  include ComfortableMexicanSofa::Tag
  
  def self.regex_tag_signature(identifier = nil)
    identifier ||= /[\w\-]+/
    /\{\{\s*cms:page:(#{identifier}):datetime\s*\}\}/
  end
  
  def content
    block.content
  end
  
end