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
    def initialize_tag_objects(content = '')
      content.scan(regex_tag_signature).flatten.collect do |label|
        self.new(:label => label)
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
    
    # Content that gets returned by the instance of the tag
    def content
      ''
    end
    
    # Content that is used during page rendering
    def render
      content
    end
  end
  
private

  # scans for cms tags inside given content
  def self.find_cms_tags(content = '')
    content.scan(/<\s*cms:.+\s*\/?>/).flatten
  end
  
  def self.initialize_tags(content = '')
    find_cms_tags(content).collect do |tag_signature|
      tag_classes.collect do |tag_class|
        tag_class.initialize_tag_objects(tag_signature)
      end
    end.flatten.compact
  end
  
  def self.included(tag)
    tag.send(:include, CmsTag::InstanceMethods)
    tag.send(:extend, CmsTag::ClassMethods)
    @@tag_classes ||= []
    @@tag_classes << tag
  end
  
  def self.tag_classes
    @@tag_classes ||= []
  end
end

# Loading all cms_tags. Need to do this manually so CmsTag module is aware
# about all defined tags.
Dir.glob(File.join(File.dirname(__FILE__), 'cms_tag', '*.rb')).each do |tag|
  require tag
end
