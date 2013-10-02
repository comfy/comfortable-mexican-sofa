class Cms::Site < ActiveRecord::Base
  include Cms::Base
  
  # -- Relationships --------------------------------------------------------
  with_options :dependent => :destroy do |site|
    site.has_many :layouts
    site.has_many :pages
    site.has_many :snippets
    site.has_many :files
    site.has_many :categories
  end
  
  # -- Callbacks ------------------------------------------------------------
  before_validation :assign_identifier,
                    :assign_hostname,
                    :assign_label
  before_save :clean_path
  after_save  :sync_mirrors
  
  # -- Validations ----------------------------------------------------------
  validates :identifier,
    :presence   => true,
    :uniqueness => true,
    :format     => { :with => /\A\w[a-z0-9_-]*\z/i }
  validates :label,
    :presence   => true
  validates :hostname,
    :presence   => true,
    :uniqueness => { :scope => :path },
    :format     => { :with => /\A[\w\.\-]+(?:\:\d+)?\z/ }
    
  # -- Scopes ---------------------------------------------------------------
  scope :mirrored, -> { where(:is_mirrored => true) }
  
  # -- Class Methods --------------------------------------------------------
  # returning the Cms::Site instance based on host and path
  def self.find_site(host, path = nil)
    return Cms::Site.first if Cms::Site.count == 1
    cms_site = nil
    Cms::Site.where(:hostname => real_host_from_aliases(host)).each do |site|
      if site.path.blank?
        cms_site = site
      elsif "#{path.to_s.split('?')[0]}/".match /^\/#{Regexp.escape(site.path.to_s)}\//
        cms_site = site
        break
      end
    end
    return cms_site
  end
  
  # -- Instance Methods -----------------------------------------------------
  # When removing entire site, let's not destroy content from other sites
  # Since before_destroy doesn't really work, this does the trick
  def destroy
    self.class.where(:id => self.id).update_all(:is_mirrored => false) if self.is_mirrored?
    super
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
    self.identifier = self.identifier.blank?? self.hostname.try(:slugify) : self.identifier
  end
  
  def assign_hostname
    self.hostname ||= self.identifier
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