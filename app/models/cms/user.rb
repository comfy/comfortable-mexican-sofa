class Cms::User < ActiveRecord::Base

  attr_reader :site_tokens
  
  include Cms::Base

  self.table_name = 'cms_users'

  devise :database_authenticatable, :rememberable, :trackable, :validatable

  # -- Relationships --------------------------------------------------------
  has_many :site_users, dependent: :destroy, class_name: 'Cms::SiteUser'
  has_many :sites, through: :site_users

  # Internal: Assign sites based on token input from form.
  def site_tokens=(ids)
    self.site_ids = ids.split(',')
  end
end
