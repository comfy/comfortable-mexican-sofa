# This module provides all Tag classes with neccessary methods.
# Example class that will behave as a Tag:
#   class MySpecialTag
#     include CmsTag
#     ...
#   end
module CmsTag
  
  TOKENIZER_REGEX = /(\{\s*cms:.*?\})|((?:[^\{]|\{(?!\s*cms:.*?\}))+)/
  
  attr_accessor :params,
                :parent
  
  module ClassMethods
    # Regex that is used to match tags in the content
    # Example:
    #   /\{\s*?cms:page:(\w+)\}/
    # will match tags like these:
    #   {cms:page:my_label}
    def regex_tag_signature
      nil
    end
    
    # Initializing tag object for a particular Tag type
    # First capture group in the regex is the tag label
    def initialize_tag(cms_page, tag_signature)
      if match = tag_signature.match(regex_tag_signature)
        if self.respond_to?(:initialize_or_find)
          self.initialize_or_find(cms_page, match[1])
        else
          tag = self.new
          tag.label   = match[1]
          tag.params  = match[2]
          tag
        end
      end
    end
  end
  
  module InstanceMethods
    
    # String indentifier of the tag
    def identifier
      "#{self.class.name.underscore}_#{self.label}"
    end
    
    # Ancestors of this tag constructed during rendering process.
    def ancestors
      node, nodes = self, []
      nodes << node = node.parent while node.parent
      nodes
    end
    
    # Regex that is used to identify instance of the tag
    # Example:
    #   /<\{\s*?cms:page:tag_label\}/
    def regex_tag_signature
      nil
    end
    
    # Content that is accociated with Tag instance.
    def content
      nil
    end
    
    # Content that is used during page rendering. Outputting existing content
    # as a default.
    def render
      content.to_s
    end
  end
  
private
  
  # Initializes a tag. It's handled by one of the tag classes
  def self.initialize_tag(cms_page, tag_signature)
    tag_instance = nil
    tag_classes.find{ |c| tag_instance = c.initialize_tag(cms_page, tag_signature) }
    tag_instance
  end
  
  # Scanning provided content and splitting it into [tag, text] tuples.
  # Tags are processed further and their content is expanded in the same way.
  # Tags are defined in the parent tags are ignored and not rendered.
  def self.process_content(cms_page, content = '', parent_tag = nil)
    tokens = content.to_s.scan(TOKENIZER_REGEX)
    tokens.collect do |tag_signature, text|
      if tag_signature
        if tag = self.initialize_tag(cms_page, tag_signature)
          tag.parent = parent_tag if parent_tag
          if tag.ancestors.select{|a| a.identifier == tag.identifier}.blank?
            cms_page.cms_tags << tag
            self.process_content(cms_page, tag.render, tag)
          end
        end
      else
        text
      end
    end.join('')
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