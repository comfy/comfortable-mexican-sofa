class CmsAsset < ActiveRecord::Base

  # -- AR Extensions --------------------------------------------------------
  
  has_attached_file :file,
    :styles => { :thumb => '60x60>' }
  
  before_post_process :image?
  
  # -- Validations ----------------------------------------------------------
  
  validates_attachment_presence :file 
  
  # -- Relationships --------------------------------------------------------
  
  belongs_to :cms_page
    
  # -- Instance Methods -----------------------------------------------------
  
  def image?
    !(file_content_type =~ /^image.*/).nil?
  end
  
  def uploaded_file=(data)
    data.content_type = MIME::Types.type_for(data.original_filename).to_s
    self.file = data
  end
  
end
