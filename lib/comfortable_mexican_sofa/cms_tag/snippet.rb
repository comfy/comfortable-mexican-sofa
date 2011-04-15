class CmsTag::Snippet < Cms::Snippet
  
  include CmsTag
  
  def identifier
    "#{self.class.name.underscore}_#{self.slug}"
  end
  
  def self.regex_tag_signature(label = nil)
    label ||= /[\w\-]+/
    /\{\{\s*cms:snippet:(#{label})\s*\}\}/
  end
  
  def content
    self.read_attribute(:content)
  end
  
end