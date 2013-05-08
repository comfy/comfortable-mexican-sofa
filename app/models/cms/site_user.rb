class Cms::SiteUser < ActiveRecord::Base
  attr_accessible :site_id, :user_id, as: :admin

  ComfortableMexicanSofa.establish_connection(self)

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
