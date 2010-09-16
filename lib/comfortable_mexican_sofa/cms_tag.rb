# This module provides all Tag classes with neccessary methods.
# Example class that will behave as a Tag:
#   class MySpecialTag
#     include CmsTag
#     ...
#   end
module CmsTag
  
  module ClassMethods
    # Regex that is used to match tags in the content
    # Example:
    #   /<\s*?cms:page:(\w+)\/?>/
    # will match tags like these:
    #   <cms:page:my_label/>
    def regex_tag_signature
      nil
    end
    
    # Initializing tag object for a particular Tag type
    # First capture group in the regex is the tag label
    def initialize_tag(cms_page, tag_signature)
      if match = tag_signature.match(regex_tag_signature)
        self.new(:label => match[1])
      end
    end
  end
  
  module InstanceMethods
    
    attr_accessor :parent
    
    def identifier
      "#{self.class.name.underscore}_#{self.label}"
    end
    
    # Regex that is used to identify instance of the tag
    # Example:
    #   /<\s*?cms:page:tag_label\/?>/
    def regex_tag_signature
      nil
    end
    
    def content=(value)
      nil
    end
    
    def content
      nil
    end
    
    # Content that is used during page rendering
    def render
      content
    end
  end
  
private
  
  # Initializes a tag. It's handled by one of the tag classes
  def self.initialize_tag(cms_page, tag_signature)
    tag_classes.find{ |c| c.initialize_tag(cms_page, tag_signature) }
  end
  
  # Scanning provided content and splitting it into [tag, text] tuples.
  # Tags are processed further and their content is expanded in the same way
  def self.process_content(cms_page, content = '')
    tokens = content.to_s.scan(/(<\s*cms:\w+:\w+\s*\/?>)|((?:[^<]|\<(?!\s*cms:\w+:\w+\s*\/?>))+)/)
    tokens.collect do |tag_signature, text|
      if tag_signature
        if tag = self.initialize_tag(tag_signature)
          self.process_content(tag.content)
        end
      else
        text
      end
    end
  end
  
  def self.included(tag)
    tag.send(:include, CmsTag::InstanceMethods)
    tag.send(:extend, CmsTag::ClassMethods)
    @@tag_classes ||= []
    @@tag_classes << tag
  end
  
  # A list of registered Tag classes
  def self.tag_classes
    @@tag_classes ||= []
  end
end