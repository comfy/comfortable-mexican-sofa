class ComfortableMexicanSofa::Tag::PageFile
  include ComfortableMexicanSofa::Tag
  
  # Signature of a tag:
  #   {{ cms:page_file:some_label:file_partial:params }}
  # Simple tag can be:
  #   {{ cms:page_file:some_label }}
  def self.regex_tag_signature(label = nil)
    label ||= /[\w\-]+/
    /\{\{\s*cms:page_file:(#{label}):?(.*?)\s*\}\}/
  end
  
  def content
    # ...
  end
  
end