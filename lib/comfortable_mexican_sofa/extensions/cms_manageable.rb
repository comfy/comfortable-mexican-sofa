# ActsAsCms is the module that drives all the logic around blocks and
# blocks_attributes.
module ComfortableMexicanSofa::CmsManageable

  def self.included(base)
    base.send :extend, ClassMethods
  end

  module ClassMethods

    def cms_manageable

      include ComfortableMexicanSofa::CmsManageable::InstanceMethods

      attr_accessor :blocks_attributes_changed

      # -- Relationships ----------------------------------------------------
      has_many :blocks,
        :autosave   => true,
        :dependent  => :destroy,
        :as         => :blockable,
        :class_name => 'Comfy::Cms::Block'

      # -- Callbacks --------------------------------------------------------
      before_save :clear_content_cache

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

    def tags=(tags)
      @tags = tags
    end

    # Array of cms_tags for a page. Content generation is called if forced.
    # These also include initialized cms_blocks if present
    def tags(force_reload = false)
      self.render if force_reload
      @tags ||= []
    end

    # Method to collect prevous state of blocks for revisions
    def blocks_attributes_was
      blocks_attributes(true)
    end

    # Cached content accessor
    def content_cache
      if (@content_cache = read_attribute(:content_cache)).nil?
        @content_cache = self.render
        update_column(:content_cache, @content_cache) unless self.new_record?
      end
      @content_cache
    end

    def clear_content_cache!
      self.update_column(:content_cache, nil)
    end

    def clear_content_cache
      write_attribute(:content_cache, nil) if self.has_attribute?(:content_cache)
    end
  end
end

ActiveRecord::Base.send :include, ComfortableMexicanSofa::CmsManageable