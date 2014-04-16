class Cms::SiteUser < ActiveRecord::Base

  include Cms::Base

  self.table_name = 'cms_site_users'

  # -- Relationships --------------------------------------------------------
  belongs_to :user, inverse_of: :site_users
  belongs_to :site

  # -- Validations ----------------------------------------------------------
  validates :user,
    presence: true
  validates :site,
    presence: true,
    uniqueness: { scope: :user }

end
