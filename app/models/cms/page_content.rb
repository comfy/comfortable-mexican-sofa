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
  before_validation :assign_full_path,
                    :escape_slug

  # after_save        :sync_child_pages
  after_find        :unescape_slug_and_path


  # -- Validations ----------------------------------------------------------
  validate :validate_variation_presence
  validates :slug,
    :presence   => true,
    :unless     => lambda{ |p| p.page.site && (p.page.site.pages.count == 0 || p.site.pages.root == self.page) }
  validate :validate_format_of_unescaped_slug

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
    return unless values.is_a?(Hash) || values.is_a?(Array)
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

  def variation_identifiers
    variations.collect {|variation| variation.identifier}
    # self.variations.pluck(:identifier)
  end

  # -- Instance Methods -----------------------------------------------------
  # For previewing purposes sometimes we need to have full_path set. This
  # full path take care of the pages and its childs but not of the site path
  def full_path
    self.read_attribute(:full_path) || self.assign_full_path
  end

  # Full url for a page
  def url
    "http://" + "#{self.site.hostname}/#{self.site.path}/#{self.full_path}".squeeze("/")
  end

  def assign_full_path
    # If it's the homepage, simply assign the fullpath and slug as 'index' and return
    if self.page.site.pages.count == 0 || self.site.pages.root == self.page
      self.full_path = '/'
      return
    end
    
    variations = self.variation_identifiers
    full_path  = generate_full_path(variations)
    if full_path
      # return self.full_path = ('/' + full_path.join('/') + '/' + self.slug).squeeze('/')
      return self.full_path = self.page.parent ? "#{CGI::escape(self.page.parent.page_content.full_path).gsub('%2F', '/')}/#{self.slug}".squeeze('/') : '/'
    else
      return false
    end
    true
  end

  # Returns false if it's impossible
  def generate_full_path(variations, slugs = [])
    parents = self.page.ancestors
    parents.each do |parent|
      parent_identifiers    = parent.page_contents.joins(:variations).where('cms_variations.identifier' => variations).pluck(:identifier)
      matching_variations   = parent_identifiers.keep_if { |varient_identifier| variations.include?(varient_identifier) }
      matching_page_content = parent.page_contents.joins(:variations).where('cms_variations.identifier' => matching_variations.first).first
      if matching_page_content && !parent.root?
        slugs << matching_page_content.slug
      elsif !parent.root?
        slugs << parent.page_content.slug
      end
    end
    slugs
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

  # Escape slug unless it's nonexistent (root)
  def escape_slug
    self.slug = CGI::escape(self.slug) unless self.slug.nil?
  end

  # Unescape the slug and full path back into their original forms unless they're nonexistent
  def unescape_slug_and_path
    self.slug       = CGI::unescape(self.slug)      unless self.slug.nil?
    self.full_path  = CGI::unescape(self.full_path) unless self.full_path.nil?
  end

  # Forcing re-saves for child pages so they can update full_paths
  def sync_child_pages
    # children.each{ |p| p.save! } if full_path_changed?
  end

  def validate_format_of_unescaped_slug
    return unless slug.present?
    unescaped_slug = CGI::unescape(self.slug)
    errors.add(:slug, :invalid) unless unescaped_slug =~ /^\p{Alnum}[\.\p{Alnum}\p{Mark}_-]*$/i
  end

end
