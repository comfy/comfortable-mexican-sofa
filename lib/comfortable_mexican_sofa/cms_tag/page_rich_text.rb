class CmsTag::PageRichText < Cms::Block
  
  include CmsTag
  
  def self.regex_tag_signature(label = nil)
    label ||= /[\w\-]+/
    /\{\{\s*cms:page:(#{label}):rich_text\s*\}\}/
  end
  
  def content=(value)
    write_attribute(:content, value)
  end
  
  def content
    read_attribute(:content)
  end
  
end