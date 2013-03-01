# encoding: utf-8

require 'csv'

# This module provides all Tag classes with neccessary methods.
# Example class that will behave as a Tag:
#   class MySpecialTag
#     include ComfortableMexicanSofa::Tag
#     ...
#   end
module ComfortableMexicanSofa::Tag
  
  TOKENIZER_REGEX   = /(\{\{\s*cms:[^{}]*\}\})|((?:\{?[^{])+|\{+)/
  IDENTIFIER_REGEX  = /\w+[\-\.\w]+\w+/
  
  attr_accessor :page,
                :identifier,
                :namespace,
                :params,
                :parent
  
  module ClassMethods
    # Regex that is used to match tags in the content
    # Example:
    #   /\{\{\s*?cms:page:(\w+)\}\}/
    # will match tags like these:
    #   {{cms:page:my_identifier}}
    def regex_tag_signature(identifier = nil)
      nil
    end
    
    # Initializing tag object for a particular Tag type
    # First capture group in the regex is the tag identifier
    # Namespace is the string separated by a dot. So if identifier is:
    # 'sidebar.about' namespace is: 'sidebar'
    def initialize_tag(page, tag_signature)
      if match = tag_signature.match(regex_tag_signature)
        
        params = begin
          (CSV.parse_line(match[2].to_s, :col_sep => ':') || []).compact
        rescue
          []
        end.map{|p| p.gsub(/\\|'/) { |c| "\\#{c}" } }
        
        tag = self.new
        tag.page        = page
        tag.identifier  = match[1]
        tag.namespace   = (ns = tag.identifier.split('.')[0...-1].join('.')).blank?? nil : ns
        tag.params      = params
        tag
      end
    end
  end
  
  module InstanceMethods
    
    # String indentifier of the tag
    def id
      "#{self.class.to_s.demodulize.underscore}_#{self.identifier}"
    end
    
    # Ancestors of this tag constructed during rendering process.
    def ancestors
      node, nodes = self, []
      nodes << node = node.parent while node.parent
      nodes
    end
    
    # Regex that is used to identify instance of the tag
    # Example:
    #   /<\{\s*?cms:page:tag_identifier\}/
    def regex_tag_signature
      self.class.regex_tag_signature(identifier)
    end
    
    # Content that is accociated with Tag instance.
    def content
      nil
    end
    
    # Content that is used during page rendering. Outputting existing content
    # as a default.
    def render
      ignore = [ComfortableMexicanSofa::Tag::Partial, ComfortableMexicanSofa::Tag::Helper].member?(self.class)
      ComfortableMexicanSofa::Tag.sanitize_irb(content, ignore)
    end
    
    # Find or initialize Cms::Block object
    def block
      page.blocks.detect{|b| b.identifier == self.identifier.to_s} || 
      page.blocks.build(:identifier => self.identifier.to_s)
    end
    
    # Checks if this tag is using Cms::Block
    def is_cms_block?
      %w(page field collection).member?(self.class.to_s.demodulize.underscore.split(/_/).first)
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
          if tag.ancestors.select{|a| a.id == tag.id}.blank?
            page.tags << tag
            self.process_content(page, tag.render, tag)
          end
        end
      else
        text
      end
    end.join('')
  end
  
  # Cleaning content from possible irb stuff. Partial and Helper tags are OK.
  def self.sanitize_irb(content, ignore = false)
    if ComfortableMexicanSofa.config.allow_irb || ignore
      content.to_s
    else
      content.to_s.gsub('<%', '&lt;%').gsub('%>', '%&gt;')
    end
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
