class CmsTag::FieldText < CmsBlock
  
  include CmsTag
  
  def self.regex_tag_signature(label = nil)
    label ||= /[\w\-]+/
    /\{\{\s*cms:field:(#{label}):?(?:text)?\s*?\}\}/
  end
  
  def content=(value)
    write_attribute(:content, value)
  end
  
  def content
    read_attribute(:content)
  end
  
  def render
    ''
  end
  
end