class ComfortableMexicanSofa::Tag::PageRichText
  include ComfortableMexicanSofa::Tag
  
  def self.regex_tag_signature(label = nil)
    label ||= /[\w\-]+/
    /\{\{\s*cms:page:(#{label}):rich_text\s*\}\}/
  end
  
  def content
    block.content
  end
  
end