class Comfy::Cms::File < ActiveRecord::Base
  self.table_name = 'comfy_cms_files'

  cms_is_categorized

  has_one_attached :attachment

  # -- Relationships -----------------------------------------------------------
  belongs_to :site

  # -- Callbacks ---------------------------------------------------------------
  before_create :assign_position

protected

  def assign_position
    max = Comfy::Cms::File.maximum(:position)
    self.position = max ? max + 1 : 0
  end
end
