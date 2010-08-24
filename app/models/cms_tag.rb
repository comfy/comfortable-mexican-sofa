module CmsTag
  
  class Error < StandardError; end
  
  module ClassMethods
    def regex_tag_signature
      raise Error, 'method not defined'
    end
  end
  
  module InstanceMethods
    def regex_tag_signature
      raise Error, 'method not defined'
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