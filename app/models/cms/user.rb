class Cms::User < ActiveRecord::Base
  attr_reader :site_tokens

  attr_accessible :email, :password, :remember_me
  attr_accessible :email, :password, :super_admin, :site_tokens, as: :admin

  ComfortableMexicanSofa.establish_connection(self)

  self.table_name = 'cms_users'

  devise :database_authenticatable, :rememberable, :trackable, :validatable

  # -- Relationships --------------------------------------------------------
  has_many :site_users, dependent: :destroy, class_name: 'Cms::SiteUsers'
  has_many :sites, through: :site_users

  # Internal: Assign sites based on token input from form.
  def site_tokens=(ids)
    self.site_ids = ids.split(',')
  end
end
