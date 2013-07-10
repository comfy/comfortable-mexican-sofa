class Cms::Variation < ActiveRecord::Base

  self.table_name = 'cms_variations'

  # -- Relationships --------------------------------------------------------
  belongs_to :content, :polymorphic => true

  # -- Validations ----------------------------------------------------------
  validates :content, :identifier,
    :presence => true
  validates :identifier,
    :uniqueness => {:scope => :content}

end