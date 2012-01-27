class ComfortableMexicanSofa::Tag::Helper
  include ComfortableMexicanSofa::Tag
  
  def self.regex_tag_signature(identifier = nil)
    identifier ||= /\w+/
    /\{\{\s*cms:helper:(#{identifier}):?(.*?)\s*\}\}/
  end
  
  def content
    if ComfortableMexicanSofa.configuration.allow_irb ||
          (!ComfortableMexicanSofa.configuration.allowed_helpers.nil? && identifier =~ ComfortableMexicanSofa.configuration.allowed_helpers) ||
          (ComfortableMexicanSofa.configuration.allowed_helpers.nil? && identifier !~ ComfortableMexicanSofa.configuration.disabled_helpers)
      "<%= #{identifier}(#{params.collect{|p| "'#{self.class.sanitize_parameter(p)}'"}.join(', ')}) %>"
    else
      ""
    end
  end
  
end