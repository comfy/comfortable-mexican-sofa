# encoding: utf-8

class Cms::PageContent < ActiveRecord::Base

  self.table_name = 'cms_page_contents'
  
  attr_accessor :tags, 
                :variation_identifiers
                
  delegate :site, :to => :page

  # -- Relationships --------------------------------------------------------
  belongs_to :page,
    :inverse_of => :page_contents
  has_many :variations, 
    :class_name => 'Cms::Variation',
    :as         => :content,
    :autosave   => true,
    :inverse_of => :content,
    :dependent  => :destroy
  has_many :blocks,
    :autosave   => true,
    :dependent  => :destroy

  # -- Callbacks ------------------------------------------------------------
  before_save :set_cached_content

  # -- Validations ----------------------------------------------------------
  validates :slug, :presence => true
  validate :validate_variation_presence

  # -- Scopes ---------------------------------------------------------------
  scope :for_variation, lambda { |*identifier|
    if ComfortableMexicanSofa.config.variations.present?
      joins(:variations).where(:cms_variations => {:identifier => identifier.first})
    else
      all
    end
  }

  # -- Instance Methods -----------------------------------------------------

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
    end
  end

  # Processing content will return rendered content and will populate 
  # self.cms_tags with instances of CmsTag
  def content(force_reload = false)
    @content = force_reload ? nil : read_attribute(:content)
    @content ||= begin
      self.tags = [] # resetting
      if page && page.layout
        ComfortableMexicanSofa::Tag.process_content(
          self,
          ComfortableMexicanSofa::Tag.sanitize_irb(page.layout.merged_content)
        )
      else
        ''
      end
    end
  end

  # Array of cms_tags for a page. Content generation is called if forced.
  # These also include initialized cms_blocks if present
  def tags(force_reload = false)
    self.content(true) if force_reload
    @tags ||= []
  end

  def variation_identifiers=(values)
    return unless values.is_a?(Hash)
    values.each do |identifier, checked|
      checked = checked.to_i == 1
      existing = self.variations.detect{|v| v.identifier == identifier}
      if checked && !existing
        self.variations.build(:identifier => identifier)
      elsif !checked && existing
        existing.mark_for_destruction
      end
    end
  end

protected

  def validate_variation_presence
    return unless ComfortableMexicanSofa.config.variations.present?
    if self.variations.reject(&:marked_for_destruction?).empty?
      self.errors.add(:base, "At least one variation required")
    end
  end

  # NOTE: This can create 'phantom' page blocks as they are defined in the layout. This is normal.
  def set_cached_content
    # write_attribute(:content, self.content(true))
  end

end
