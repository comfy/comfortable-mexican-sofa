class ComfortableMexicanSofa::Tag::Helper
  include ComfortableMexicanSofa::Tag
  
  def self.regex_tag_signature(identifier = nil)
    identifier ||= /[\w\-]+/
    /\{\{\s*cms:helper:(#{identifier}):?(.*?)\s*\}\}/
  end
  
  def content
    "<%= #{identifier}(#{params.collect{|p| "'#{p}'"}.join(', ')}) %>"
  end
  
end