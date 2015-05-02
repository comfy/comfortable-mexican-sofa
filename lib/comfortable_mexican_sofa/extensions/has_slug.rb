# encoding: utf-8

module ComfortableMexicanSofa::HasSlug
  def self.included(base)
    base.send :extend, ClassMethods
  end

  module ClassMethods
    def cms_has_slug
      include ComfortableMexicanSofa::HasSlug::InstanceMethods

      before_validation :escape_slug,
                        :assign_full_path
      after_find        :unescape_slug_and_path

      validate :validate_format_of_unescaped_slug
    end
  end

  module InstanceMethods
    # For previewing purposes sometimes we need to have full_path set. This
    # full path take care of the pages and its childs but not of the site path
    def full_path
      read_attribute(:full_path) || assign_full_path
    end

    # Full url for a page
    def url(relative = false)
      public_cms_path = ComfortableMexicanSofa.config.public_cms_path || '/'
      if relative
        [public_cms_path, self.site.path, self.full_path].join('/').squeeze('/')
      else
        '//' + [self.site.hostname, public_cms_path, self.site.path, self.full_path].join('/').squeeze('/')
      end
    end

    protected
      def assign_full_path
        assign_parent # Need to make sure we already have the parent here!
        self.full_path = parent ? "#{CGI::escape(parent.full_path).gsub('%2F', '/')}/#{slug}".squeeze('/') : '/'
      end

      def validate_format_of_unescaped_slug
        return unless slug.present?
        unescaped_slug = CGI::unescape(self.slug)
        errors.add(:slug, :invalid) unless unescaped_slug =~ /^\p{Alnum}[\.\p{Alnum}\p{Mark}_-]*$/i
      end

      # Escape slug unless it's nonexistent (root)
      def escape_slug
        self.slug = CGI::escape(self.slug) unless self.slug.nil?
      end

      # Unescape the slug and full path back into their original forms unless they're nonexistent
      def unescape_slug_and_path
        self.slug       = CGI::unescape(self.slug)      unless self.slug.nil?
        self.full_path  = CGI::unescape(self.full_path) unless self.full_path.nil?
      end
  end

end

ActiveRecord::Base.send :include, ComfortableMexicanSofa::HasSlug
