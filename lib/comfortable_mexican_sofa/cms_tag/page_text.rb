class CmsTag::PageText < CmsBlock
  
  include CmsTag
  
  def self.regex_tag_signature(label = nil)
    label ||= /\w+/
    /\{\{\s*cms:page:(#{label}):?(?:text)?\s*\}\}/
  end
  
  def regex_tag_signature
    self.class.regex_tag_signature(label)
  end
  
  def content=(value)
    write_attribute(:content_text, value)
  end
  
  def content
    read_attribute(:content_text)
  end
  
end