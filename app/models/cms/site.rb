class Cms::Site < ActiveRecord::Base
  
  ComfortableMexicanSofa.establish_connection(self)
  
  self.table_name = 'cms_sites'
  
  # -- Relationships --------------------------------------------------------
  has_many :layouts,    :dependent => :delete_all
  has_many :pages,      :dependent => :delete_all
  has_many :snippets,   :dependent => :delete_all
  has_many :files,      :dependent => :destroy
  has_many :categories, :dependent => :delete_all
  
  # -- Callbacks ------------------------------------------------------------
  before_validation :assign_identifier,
                    :assign_label
  before_save :clean_path
  after_save  :sync_mirrors
  
  # -- Validations ----------------------------------------------------------
  validates :identifier,
    :presence   => true,
    :uniqueness => true,
    :format     => { :with => /^\w[a-z0-9_-]*$/i }
  validates :label,
    :presence   => true
  validates :hostname,
    :presence   => true,
    :uniqueness => { :scope => :path },
    :format     => { :with => /^[\w\.\-]+$/ }
    
  # -- Scopes ---------------------------------------------------------------
  scope :mirrored, where(:is_mirrored => true)
  
  # -- Class Methods --------------------------------------------------------
  # returning the Cms::Site instance based on host and path
  def self.find_site(host, path = nil)
    return Cms::Site.first if Cms::Site.count == 1
    cms_site = nil
    Cms::Site.find_all_by_hostname(real_host_from_aliases(host)).each do |site|
      if site.path.blank?
        cms_site = site
      elsif "#{path}/".match /^\/#{Regexp.escape(site.path.to_s)}\//
        cms_site = site
        break
      end
    end
    return cms_site
  end

protected
  
  def self.real_host_from_aliases(host)
    if aliases = ComfortableMexicanSofa.config.hostname_aliases
      aliases.each do |alias_host, aliases|
        return alias_host if aliases.include?(host)
      end
    end
    host
  end

  def assign_identifier
    self.identifier = self.identifier.blank?? self.hostname.try(:idify) : self.identifier
  end
  
  def assign_label
    self.label = self.label.blank?? self.identifier.try(:titleize) : self.label
  end
  
  def clean_path
    self.path ||= ''
    self.path.squeeze!('/')
    self.path.gsub!(/\/$/, '')
  end
  
  # When site is marked as a mirror we need to sync its structure
  # with other mirrors.
  def sync_mirrors
    return unless is_mirrored_changed? && is_mirrored?
    
    [self, Cms::Site.mirrored.where("id != #{id}").first].compact.each do |site|
      (site.layouts(:reload).roots + site.layouts.roots.map(&:descendants)).flatten.map(&:sync_mirror)
      (site.pages(:reload).roots + site.pages.roots.map(&:descendants)).flatten.map(&:sync_mirror)
      site.snippets(:reload).map(&:sync_mirror)
    end
  end
  
end