class ComfortableMexicanSofa::Tag::PageFile
  include ComfortableMexicanSofa::Tag
  
  # Signature of a tag:
  #   {{ cms:page_file:some_label:type:params }}
  # Simple tag can be:
  #   {{ cms:page_file:some_label }}
  def self.regex_tag_signature(label = nil)
    label ||= /[\w\-]+/
    /\{\{\s*cms:page_file:(#{label}):?(.*?)\s*\}\}/
  end
  
  # Type of the tag controls how file is rendered
  def type
    %w(partial url image link).member?(params[0]) ? params[0] : 'url'
  end
  
  def content
    # ...
  end
  
end