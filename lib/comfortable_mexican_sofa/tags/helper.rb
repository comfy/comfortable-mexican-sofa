class ComfortableMexicanSofa::Tag::Helper
  include ComfortableMexicanSofa::Tag
  
  def self.regex_tag_signature(identifier = nil)
    identifier ||= /[\w\-]+/
    /\{\{\s*cms:helper:(#{identifier}):?(.*?)\s*\}\}/
  end
  
  def content
    if identifier =~ ComfortableMexicanSofa.configuration.allowed_helpers || ComfortableMexicanSofa.configuration.allow_irb
      "<%= #{identifier}(#{params.collect{|p| "'#{self.class.sanitize_parameter(p)}'"}.join(', ')}) %>"
    else
      ""
    end
  end
  
end