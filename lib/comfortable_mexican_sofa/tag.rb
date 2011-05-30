# This module provides all Tag classes with neccessary methods.
# Example class that will behave as a Tag:
#   class MySpecialTag
#     include CmsTag
#     ...
#   end
module ComfortableMexicanSofa::Tag
  
  TOKENIZER_REGEX = /(\{\{\s*cms:[^{}]*\}\})|((?:\{?[^{])+|\{+)/
  
  attr_accessor :page,
                :label,
                :params,
                :parent
  
  module ClassMethods
    # Regex that is used to match tags in the content
    # Example:
    #   /\{\{\s*?cms:page:(\w+)\}\}/
    # will match tags like these:
    #   {{cms:page:my_label}}
    def regex_tag_signature(label = nil)
      nil
    end
    
    # Initializing tag object for a particular Tag type
    # First capture group in the regex is the tag label
    def initialize_tag(page, tag_signature)
      if match = tag_signature.match(regex_tag_signature)
        tag = self.new
        tag.page    = page
        tag.label   = match[1]
        tag.params  = match[2]
        tag
      end
    end
  end
  
  module InstanceMethods
    
    # String indentifier of the tag
    def identifier
      "#{self.class.to_s.demodulize.underscore}_#{self.label}"
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
      self.class.regex_tag_signature(label)
    end
    
    # Content that is accociated with Tag instance.
    def content
      nil
    end
    
    # Content that is used during page rendering. Outputting existing content
    # as a default.
    def render
      # cleaning content from possible irb stuff. Partial and Helper tags are OK.
      if !ComfortableMexicanSofa.config.allow_irb && 
          ![ComfortableMexicanSofa::Tag::Partial, ComfortableMexicanSofa::Tag::Helper].member?(self.class)
        content.to_s.gsub('<%', '&lt;%').gsub('%>', '%&gt;')
      else
        content.to_s
      end
    end
    
    # Find or initialize Cms::Block object
    def block
      page.blocks.detect{|b| b.label == self.label.to_s} || page.blocks.build(:label => self.label.to_s)
    end
    
    # Find or initialize Cms::Snippet object
    def snippet
      page.site.snippets.detect{|s| s.slug == self.label.to_s} || page.site.snippets.build(:slug => self.label.to_s)
    end
    
    def upload
      if ComfortableMexicanSofa.config.enable_mirror_sites 
        Cms::Upload.all.detect{|s| s.file_file_name == self.label.to_s} || Cms::Upload.all.build(:file_file_name => self.label.to_s)
      else
        page.site.uploads.detect{|s| s.file_file_name == self.label.to_s} || page.site.uploads.build(:file_file_name => self.label.to_s)
      end
    end
    
    # Checks if this tag is using Cms::Block
    def is_cms_block?
      %w(page field).member?(self.class.to_s.demodulize.underscore.split(/_/).first)
    end
    
    # Used in displaying form elements for Cms::Block
    def record_id
      block.id
    end
  end
  
private
  
  # Initializes a tag. It's handled by one of the tag classes
  def self.initialize_tag(page, tag_signature)
    tag_instance = nil
    tag_classes.find{ |c| tag_instance = c.initialize_tag(page, tag_signature) }
    tag_instance
  end
  
  # Scanning provided content and splitting it into [tag, text] tuples.
  # Tags are processed further and their content is expanded in the same way.
  # Tags are defined in the parent tags are ignored and not rendered.
  def self.process_content(page, content = '', parent_tag = nil)
    tokens = content.to_s.scan(TOKENIZER_REGEX)
    tokens.collect do |tag_signature, text|
      if tag_signature
        if tag = self.initialize_tag(page, tag_signature)
          tag.parent = parent_tag if parent_tag
          if tag.ancestors.select{|a| a.identifier == tag.identifier}.blank?
            page.tags << tag
            self.process_content(page, tag.render, tag)
          end
        end
      else
        text
      end
    end.join('')
  end
  
  def self.included(tag)
    tag.send(:include, ComfortableMexicanSofa::Tag::InstanceMethods)
    tag.send(:extend, ComfortableMexicanSofa::Tag::ClassMethods)
    @@tag_classes ||= []
    @@tag_classes << tag
  end
  
  # A list of registered Tag classes
  def self.tag_classes
    @@tag_classes ||= []
  end
end