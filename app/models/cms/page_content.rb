# encoding: utf-8

class Cms::PageContent < ActiveRecord::Base

  self.table_name = 'cms_page_contents'

  belongs_to :page
  has_many :variations, 
    :class_name => 'Cms::Variation',
    :as         => :content

  scope :for_variation, lambda {|*identifier|
    if ComfortableMexicanSofa.config.variations.present?
      joins(:variations).where(:cms_variations => {:identifier => identifier})
    else
      all
    end
  }

end
