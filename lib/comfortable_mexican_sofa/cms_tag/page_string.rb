class CmsTag::PageString < Cms::Block
  
  include CmsTag
  
  def self.regex_tag_signature(label = nil)
    label ||= /[\w\-]+/
    /\{\{\s*cms:page:(#{label}):string\s*\}\}/
  end
  
  def content=(value)
    write_attribute(:content, value)
  end
  
  def content
    read_attribute(:content)
  end
  
end