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
      ''
    end
  end
  
private

  def self.included(tag)
    tag.send(:include, CmsTag::InstanceMethods)
    tag.send(:extend, CmsTag::ClassMethods)
    @@tag_instances ||= []
    @@tag_instances << tag
  end
  
  def self.tag_instances
    @@tag_instances
  end
end

# Loading all cms_tags
Dir.glob(File.join(File.dirname(__FILE__), 'cms_tags', '*.rb')).each do |tag|
  require tag
end