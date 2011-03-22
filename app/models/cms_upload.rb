class CmsUpload < ActiveRecord::Base

  # -- AR Extensions --------------------------------------------------------
  has_attached_file :file, ComfortableMexicanSofa.config.upload_file_options
  
  # -- Relationships --------------------------------------------------------
  belongs_to :cms_site
  
  # -- Validations ----------------------------------------------------------
  validates :cms_site_id, :presence => true
  validates_attachment_presence :file
  
end
