class Comfy::Cms::Block < ActiveRecord::Base
  self.table_name = 'comfy_cms_blocks'
  
  # -- Relationships --------------------------------------------------------
  belongs_to :blockable,
    :polymorphic  => true
  has_many :files,
    :autosave     => true,
    :dependent    => :destroy
  
  # -- Callbacks ------------------------------------------------------------
  before_save :prepare_files
  
  # -- Validations ----------------------------------------------------------
  validates :identifier,
    :presence   => true,
    :uniqueness => { :scope => [:blockable_type, :blockable_id] }
    
  # -- Instance Methods -----------------------------------------------------
  # Tag object that is using this block
  def tag
    @tag ||= blockable.tags(:reload).detect{|t| t.is_cms_block? && t.identifier == identifier}
  end
  

  def render
    tag.try(:render)
  end

protected
  
  def prepare_files
    temp_files = [self.content].flatten.select do |f|
      %w(ActionDispatch::Http::UploadedFile Rack::Test::UploadedFile File).member?(f.class.name)
    end
    
    return if temp_files.blank?
    
    # only accepting one file if it's PageFile. PageFiles will take all
    single_file = self.tag.instance_of?(ComfortableMexicanSofa::Tag::PageFile)
    temp_files = [temp_files.first].compact if single_file
    
    temp_files.each do |file|
      self.files.collect{|f| f.mark_for_destruction } if single_file
      self.files.build(:site => self.blockable.site, :dimensions => self.tag.try(:dimensions), :file => file)
    end
    
    self.content = nil unless self.content.is_a?(String)
  end
end
