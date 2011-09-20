class Cms::File < ActiveRecord::Base
  
  ComfortableMexicanSofa.establish_connection(self)
    
  set_table_name :cms_files
  
  cms_is_categorized
  
  attr_accessor :layout_id,
                :page_id,
                :snippet_id
  
  # -- AR Extensions --------------------------------------------------------
  has_attached_file :file, ComfortableMexicanSofa.config.upload_file_options
  
  # -- Relationships --------------------------------------------------------
  belongs_to :site
  
  # -- Validations ----------------------------------------------------------
  validates :site_id, :presence => true
  validates_attachment_presence :file
  
  validates_uniqueness_of :file_file_name,
    :scope => :site_id
  
  # -- Callbacks ------------------------------------------------------------
  before_save :assign_label,
              :categorize_file
  
protected
  
  def assign_label
    self.label = self.label.blank?? self.file_file_name.gsub(/\.[^\.]*?$/, '').titleize : self.label
  end
  
  def categorize_file
    category = if layout_id && layout = site.layouts.find_by_id(layout_id)
      Cms::Category.find_or_create_by_label_and_categorized_type("[layout] #{layout.slug}", 'Cms::File')
    elsif page_id && page = site.pages.find_by_id(page_id)
      Cms::Category.find_or_create_by_label_and_categorized_type("[page] #{page.full_path}", 'Cms::File')
    elsif snippet_id && snippet = site.snippets.find_by_id(snippet_id)
      Cms::Category.find_or_create_by_label_and_categorized_type("[snippet] #{snippet.slug}", 'Cms::File')
    end
    self.category_ids = { category.id => 1 } if category
  end
  
end
