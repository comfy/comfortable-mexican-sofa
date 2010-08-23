class CmsPage < ActiveRecord::Base
  
  belongs_to :cms_layout
  
  has_many :page_contents, :dependent => :destroy
  
end
