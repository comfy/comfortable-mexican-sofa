class CmsLayout < ActiveRecord::Base
  
  # -- Relationships --------------------------------------------------------

  acts_as_tree :counter_cache => :children_count
  has_many :cms_pages, :dependent => :nullify
  
  # -- Validations ----------------------------------------------------------

  validates_presence_of :label
  validates_uniqueness_of :label
  validate :validate_block_presence,
           :validate_proper_relationship
  
  # -- AR Callbacks ---------------------------------------------------------

  before_save :flag_as_extendable,
              :update_page_blocks
  
  # -- Scopes ---------------------------------------------------------------

  default_scope :order => 'position ASC'

  scope :extendable,
    :conditions => { :is_extendable => true }
  
  # -- Class Methods --------------------------------------------------------
  
  def self.create_default_layout!(options = { })
    create({
      :label => "Default Layout",
      :app_layout => "application",
      :content => "{{cms_page_block:default:code}}",
      :is_extendable => true
    }.merge(options))
  end

  def self.options_for_select
    CmsLayout.all(:select => 'id, label').collect { |l| [ l.label, l.id ] }
  end
  
  def self.app_layouts_for_select
    path = "#{Rails.root}/app/views/layouts"
    regex = /^([a-z0-9]\w+)\.html/i
    
    app_layouts =
      begin
        Dir.entries(path).collect do |l|
          l.match(regex).try(:captures)
        end.compact.flatten
      rescue
        # No application layouts are present
      end
    
    [ [ '---', nil ] ] + (app_layouts.blank? ? [ ] : app_layouts)
  end
  
  # -- Instance Methods -----------------------------------------------------

  def content
    if parent
      parent.content.gsub(/\{\{\s*cms_page_block:default:.*?\}\}/, self.read_attribute(:content))
    else
      read_attribute(:content)
    end
  end
  
  def app_layout
    this_layout = read_attribute(:app_layout)
    if this_layout.blank?
      parent && parent.app_layout
    else
      this_layout
    end
  end
  
  def extendable_for_select
    [['---', nil]] + CmsLayout.extendable.all.reject{|l| ([self]+self.descendants).member?(l)}.collect{ |l| [l.label, l.id] }
  end
  
  def tags(options = {})
    CmsTag::parse_tags(self.content, options)
  end
  
protected

  def validate_block_presence
    self.errors.add(:content, 'does not have any cms_blocks defined') if self.tags.empty?
  end
  
  def validate_proper_relationship
    if self.descendants.member?(parent) || self.parent == self
      self.errors.add(:parent_id, 'layout is invalid') 
    end
  end
  
  def validate_children_against_extendable
    # todo
  end
  
  def flag_as_extendable
    self.is_extendable = !self.tags.select{|t| t.tag_type == 'cms_page_block' && t.label == 'default'}.blank?
    true
  end
  
  def update_page_blocks
    return if new_record? || !content_changed?
    
    old_tags = CmsTag::parse_tags(content_was).select{|t| ['cms_block', 'cms_page_block'].member?(t.tag_type)}.collect{|t| t.label}
    new_tags = CmsTag::parse_tags(content).select{|t| ['cms_block', 'cms_page_block'].member?(t.tag_type)}.collect{|t| t.label}
    
    # creating new cms_blocks for all pages using this layout
    labels_for_blocks = new_tags - old_tags
    if !labels_for_blocks.blank?
      cms_pages.each do |cms_page|
        labels_for_blocks.each do |label|
          cms_page.cms_blocks.create(:label => label)
        end
      end
    end
  end
end
