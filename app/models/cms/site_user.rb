class Cms::SiteUser < ActiveRecord::Base

  include Cms::Base

  self.table_name = 'cms_site_users'

  # -- Relationships --------------------------------------------------------
  belongs_to :user
  belongs_to :site

  # -- Validations ----------------------------------------------------------
  validates :user_id,
    presence: true
  validates :site_id,
    presence: true,
    uniqueness: { scope: :user_id }

end
