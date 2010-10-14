class CmsUpload < ActiveRecord::Base

  # -- AR Extensions --------------------------------------------------------
  has_attached_file :file,
    :styles => { :thumb => '48x48>' }
  
  before_post_process :image?
  
  # -- Relationships --------------------------------------------------------
  belongs_to :cms_site
  
  # -- Validations ----------------------------------------------------------
  validates_attachment_presence :file 
  
  # -- Instance Methods -----------------------------------------------------
  def image?
    !(file_content_type =~ /^image.*/).nil?
  end
  
  def uploaded_file=(data)
    if data.present?
      data.content_type = MIME::Types.type_for(data.original_filename).to_s
      self.file = data
    end
  end
  
  def icon
    if self.image?
      self.file.url(:thumb)
    else
      ext = self.file_file_name.split('.').last
      FILE_ICONS.include?(ext) ? "cms/file_icons/#{ext}.png" : "cms/file_icons/_blank.png"
    end
  end
  
end
