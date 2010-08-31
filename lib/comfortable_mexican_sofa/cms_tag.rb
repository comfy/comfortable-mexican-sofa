# This module provides all Tag classes with neccessary methods.
# Example class that will behave as a Tag:
#   class MySpecialTag
#     include CmsTag
#     ...
#   end
module CmsTag
  
  # All tags must follow this format:
  #   <cms:*>
  TAG_PREFIX = 'cms'
  
  module ClassMethods
    # Regex that is used to match tags in the content
    # Example:
    #   /<\s*?cms:page:(\w+)\/?>/
    # will match tags like these:
    #   <cms:page:my_label/>
    def regex_tag_signature
      nil
    end
    
    # Initializing tag objects for a particular Tag type
    def initialize_tag_objects(cms_page = nil, content = '')
      content.to_s.scan(regex_tag_signature).flatten.collect do |label|
        if self.superclass == CmsBlock && cms_page
          cms_page.cms_blocks.detect{|b| b.label == label} || self.new(:label => label)
        else
          self.new(:label => label)
        end
      end
    end
  end
  
  module InstanceMethods
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
  
  # scans for cms tags inside given content
  def self.find_cms_tags(content = '')
    content.to_s.scan(/<\s*#{TAG_PREFIX}:.+\s*\/?>/).flatten
  end
  
  # Scans provided content and initializes Tag objects based
  # on their tag signature.
  def self.initialize_tags(cms_page = nil, content = '')
    # content is set based on the cms_page layout content
    content = cms_page.cms_layout.try(:content) if cms_page
    
    cms_tags = find_cms_tags(content).collect do |tag_signature|
      tag_classes.collect do |tag_class|
        tag_class.initialize_tag_objects(cms_page, tag_signature)
      end
    end.flatten.compact
    
    # Initializing cms_blocks for the passed cms_page
    cms_page.cms_blocks = cms_tags.select{|t| t.class.superclass == CmsBlock} if cms_page
    return cms_tags
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