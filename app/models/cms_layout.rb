class CmsLayout < ActiveRecord::Base
  
  has_many :cms_pages, :dependent => :nullify
  
end
