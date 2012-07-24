class Cms::SiteAlias < ActiveRecord::Base

  ComfortableMexicanSofa.establish_connection(self)

  self.table_name = 'cms_site_aliases'

	attr_accessible :hostname

  # -- Relationships --------------------------------------------------------
  belongs_to :site

  # -- Callbacks ------------------------------------------------------------

  # -- Validations ----------------------------------------------------------
  validates :site_id,
    :presence   => true
  validates :hostname,
    :presence   => true,
    :uniqueness => { :scope => :site_id },
    :format     => { :with => /^[\w\.\-]+$/ }

  # -- Scopes ---------------------------------------------------------------

  # -- Class Methods --------------------------------------------------------

end
