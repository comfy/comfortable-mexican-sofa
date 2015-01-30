# This module is added to pages to make them translateable.

module ComfortableMexicanSofa::IsTranslateable
  def self.included(base)
    base.send :extend, ClassMethods
  end

  module ClassMethods
    def cms_is_translateable
      include ComfortableMexicanSofa::IsTranslateable::InstanceMethods

      attr_accessor :translation

      has_many :translations,
        :as => :translateable,
        :dependent => :destroy
    end
  end

  module InstanceMethods
    # Returns *true* if the page has translations (any translations if no locale
    # is specified or a translation for the given locale.)
    def translations?(locale=nil)
      locale ? translations.find_by_locale(locale).any? : translations.any?
    end

    # Returns a array of locales for which translations are available.
    def available_locales(include_default_locale=true)
      include_default_locale ? ["#{site.locale} (default)"] + available_locales(false) : translations.map(&:locale)
    end

    # Make sure we remove the content cache for translations too.
    def clear_content_cache!
      translations.each { |translation| translation.clear_content_cache! }
      super
    end

  end
end

ActiveRecord::Base.send :include, ComfortableMexicanSofa::IsTranslateable
