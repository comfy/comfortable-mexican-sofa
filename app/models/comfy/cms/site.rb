# frozen_string_literal: true

class Comfy::Cms::Site < Comfy::Cms::ApplicationRecord

  self.table_name = "comfy_cms_sites"

  # Ensuring that path is always of "/foo/bar" format
  normalizes :path, apply_to_nil: true, with: -> (path) do
    path = "/#{path}".gsub(%r{\s}, "").to_s.squeeze("/").sub(%r{/+\z}, "")
    path.blank? ? "/" : path
  end

  # -- Relationships -----------------------------------------------------------
  with_options dependent: :destroy do |site|
    site.has_many :layouts
    site.has_many :pages
    site.has_many :snippets
    site.has_many :files
    site.has_many :categories
  end

  # -- Callbacks ---------------------------------------------------------------
  before_validation :assign_identifier,
                    :assign_hostname,
                    :assign_label

  # -- Validations -------------------------------------------------------------
  validates :identifier,
    presence:   true,
    uniqueness: true,
    format:     { with: %r{\A\w[a-z0-9_-]*\z}i }
  validates :label,
    presence:   true
  validates :hostname,
    presence:   true,
    uniqueness: { scope: :path },
    format:     { with: %r{\A[\w.-]+(?:\:\d+)?\z} }

  # -- Class Methods -----------------------------------------------------------
  # Returning Comfy::Cms::Site instance based on the given host and path.
  # Note that path is request.fullpath that looks like this: `/foo/bar?eggs=bacon`
  # Hitting root makes path `/` so it helps if site.path is properly normalized
  def self.find_site(hostname:, path: "/")
    # If there's only one site, we just return it
    if Comfy::Cms::Site.one?
      return Comfy::Cms::Site.first
    end

    # sometimes real hosthame is hiding behind an alias
    real_host_from_aliases = -> (hostname) do
      if (aliases = ComfortableMexicanSofa.config.hostname_aliases)
        aliases.each do |alias_hostname, hostnames|
          return alias_hostname if hostnames.include?(hostname)
        end
      end
      hostname
    end

    # from multiple sites we need to choose one with the correct path
    if (sites = Comfy::Cms::Site.where(hostname: real_host_from_aliases.call(hostname)))
      sites.each do |site|
        if path.start_with?("#{ComfortableMexicanSofa.configuration.public_cms_path}/#{site.path}".squeeze("/"))
          return site
        end
      end
    end

    # we found nothing
    return nil
  end

  # -- Instance Methods --------------------------------------------------------
  def url(relative: false)
    public_cms_path = ComfortableMexicanSofa.config.public_cms_path || "/"
    host = "//#{hostname}"
    path = ["/", public_cms_path, self.path].compact.join("/").squeeze("/").chomp("/")
    relative ? path.presence : [host, path].join
  end

protected

  def assign_identifier
    self.identifier = identifier.blank? ? hostname.try(:parameterize) : identifier
  end

  def assign_hostname
    self.hostname ||= identifier
  end

  def assign_label
    self.label = label.blank? ? identifier.try(:titleize) : label
  end

end
