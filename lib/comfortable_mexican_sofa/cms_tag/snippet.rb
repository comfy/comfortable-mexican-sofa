class ComfortableMexicanSofa::Tag::Snippet < Cms::Snippet
  include ComfortableMexicanSofa::Tag
  
  def identifier
    "#{self.class.to_s.demodulize.underscore}_#{self.slug}"
  end
  
  def self.regex_tag_signature(label = nil)
    label ||= /[\w\-]+/
    /\{\{\s*cms:snippet:(#{label})\s*\}\}/
  end
  
  def content
    self.read_attribute(:content)
  end
  
end