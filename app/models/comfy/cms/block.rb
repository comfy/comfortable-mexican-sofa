class Comfy::Cms::Block < ActiveRecord::Base
  self.table_name = 'comfy_cms_blocks'

  FILE_CLASSES = %w(ActionDispatch::Http::UploadedFile Rack::Test::UploadedFile File).freeze

  serialize :content

  attr_accessor :temp_files

  # -- Relationships --------------------------------------------------------
  belongs_to :blockable,
    :polymorphic  => true
  has_many :files,
    :autosave   => true,
    :dependent  => :destroy

  # -- Validations ----------------------------------------------------------
  validates :identifier,
    :presence   => true,
    :uniqueness => { :scope => [:blockable_type, :blockable_id] }

  # -- Callbacks ------------------------------------------------------------
  before_save :prepare_files

  # -- Instance Methods -----------------------------------------------------
  # Tag object that is using this block
  def tag
    @tag ||= blockable.tags(:reload).detect{|t| t.is_cms_block? && t.identifier == identifier}
  end

  # Intercepting assigns as we can't cram files into content directly anymore
  def content=(value)
    self.temp_files = [value].flatten.select do |f|
      FILE_CLASSES.member?(f.class.name)
    end

    # correctly triggering dirty
    value = nil               if self.temp_files.present?
    write_attribute(:content, value)
    self.content_will_change! if self.temp_files.present?
  end

protected

  # If we're passing actual files into content attribute, let's build them.
  def prepare_files
    return if self.temp_files.blank?

    # only accepting one file if it's PageFile. PageFiles will take all
    single_file = self.tag.instance_of?(ComfortableMexicanSofa::Tag::PageFile)
    self.temp_files = [self.temp_files.first].compact if single_file

    self.temp_files.each do |file|
      self.files.collect{|f| f.mark_for_destruction } if single_file

      self.files.build(
        :site       => self.blockable.site,
        :dimensions => self.tag.try(:dimensions),
        :file       => file
      )
    end
  end
end
