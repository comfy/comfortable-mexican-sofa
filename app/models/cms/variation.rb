class Cms::Variation < ActiveRecord::Base

  self.table_name = 'cms_variations'

  # -- Relationships --------------------------------------------------------
  belongs_to :content,
    :polymorphic => true,
    :inverse_of  => :variations


  # -- Validations ----------------------------------------------------------
  validates :content, :identifier,
    :presence => true
  validates :identifier,
    :uniqueness => {:scope => :content}
  validate :validate_uniqueness_per_page

protected

  def validate_uniqueness_per_page
    exists = self.content.page.page_contents.for_variation(self.identifier)
      .where('cms_page_contents.id NOT IN (?)', (self.content.id || 0)).exists?
    self.errors.add(:identifier, 'That identifier already exists') if exists
  end

end