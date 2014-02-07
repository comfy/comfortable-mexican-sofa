module ComfortableMexicanSofa::ActsAsCms
  
  def self.included(base)
    base.send :extend, ClassMethods
  end
  
  module ClassMethods

    def cms_acts_as_cms

      include ComfortableMexicanSofa::ActsAsCms::InstanceMethods

      cms_has_revisions_for :blocks_attributes

      attr_accessor :tags,
                    :cached_content,
                    :blocks_attributes_changed

      # -- Relationships ----------------------------------------------------
      has_many :blocks,
        :autosave   => true,
        :dependent  => :destroy,
        :as         => :blockable

      # -- Callbacks --------------------------------------------------------
      before_save  :set_cached_content


    end
  end
  
  module InstanceMethods

    # Transforms existing cms_block information into a hash that can be used
    # during form processing. That's the only way to modify cms_blocks.
    def blocks_attributes(was = false)
      self.blocks.collect do |block|
        block_attr = {}
        block_attr[:identifier] = block.identifier
        block_attr[:content]    = was ? block.content_was : block.content
        block_attr
      end
    end
    
    # Array of block hashes in the following format:
    #   [
    #     { :identifier => 'block_1', :content => 'block content' },
    #     { :identifier => 'block_2', :content => 'block content' }
    #   ]
    def blocks_attributes=(block_hashes = [])
      block_hashes = block_hashes.values if block_hashes.is_a?(Hash)
      block_hashes.each do |block_hash|
        block_hash.symbolize_keys! unless block_hash.is_a?(HashWithIndifferentAccess)
        block = 
          self.blocks.detect{|b| b.identifier == block_hash[:identifier]} || 
          self.blocks.build(:identifier => block_hash[:identifier])
        block.content = block_hash[:content]
        self.blocks_attributes_changed = self.blocks_attributes_changed || block.content_changed?
      end
    end

    # Processing content will return rendered content and will populate 
    # self.cms_tags with instances of CmsTag
    def render
      @tags = [] # resetting
      return '' unless layout
      
      ComfortableMexicanSofa::Tag.process_content(
        self, ComfortableMexicanSofa::Tag.sanitize_irb(layout.merged_content)
      )
    end

    # Method to collect prevous state of blocks for revisions
    def blocks_attributes_was
      blocks_attributes(true)
    end

    # Cached content accessor
    def content
      if (@cached_content = read_attribute(:content)).nil?
        @cached_content = self.render
        update_column(:content, @cached_content) unless self.new_record?
      end
      @cached_content
    end
    
    def clear_cached_content!
      self.update_column(:content, nil)
    end
    
    def set_cached_content
      @cached_content = self.render
      write_attribute(:content, self.cached_content)
    end

  end
end

ActiveRecord::Base.send :include, ComfortableMexicanSofa::ActsAsCms