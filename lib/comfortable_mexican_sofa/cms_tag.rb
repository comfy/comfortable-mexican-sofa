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
    # pass :cms_page => cms_page to initialize them in context of a page
    def initialize_tag_objects(content = '', options = {})
      content.scan(regex_tag_signature).flatten.collect do |label|
        # if tag extends CmsBlock, initialize it based on data in the db
        if self.superclass == CmsBlock && (cms_page = options[:cms_page]) && cms_page.is_a?(CmsPage)
          cms_page.cms_blocks << (cms_block = 
            cms_page.cms_blocks.find_by_label(label) ||
            self.new(:label => label)
          )
          cms_block
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
    content.scan(/<\s*#{TAG_PREFIX}:.+\s*\/?>/).flatten
  end
  
  # Scans provided content and initializes Tag objects based
  # on their tag signature.
  # Pass :cms_page => @cms_page to initialize tag objects based on the page context.
  # Pass :cms_blocks_only => true to initialize CmsBlock subclasses
  def self.initialize_tags(content = '', options = {})
    find_cms_tags(content).collect do |tag_signature|
      tag_classes.collect do |tag_class|
        tag_class.initialize_tag_objects(tag_signature, options)
      end
    end.flatten.compact
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