# frozen_string_literal: true

# Loading engine only if this is not a standalone installation
unless defined? ComfortableMexicanSofa::Application
  require_relative "comfortable_mexican_sofa/engine"
end

require_relative "comfortable_mexican_sofa/version"
require_relative "comfortable_mexican_sofa/error"
require_relative "comfortable_mexican_sofa/configuration"
require_relative "comfortable_mexican_sofa/routing"
require_relative "comfortable_mexican_sofa/access_control/admin_authentication"
require_relative "comfortable_mexican_sofa/access_control/admin_authorization"
require_relative "comfortable_mexican_sofa/access_control/public_authentication"
require_relative "comfortable_mexican_sofa/access_control/public_authorization"
require_relative "comfortable_mexican_sofa/render_methods"
require_relative "comfortable_mexican_sofa/view_hooks"
require_relative "comfortable_mexican_sofa/form_builder"
require_relative "comfortable_mexican_sofa/seeds"
require_relative "comfortable_mexican_sofa/seeds/layout/importer"
require_relative "comfortable_mexican_sofa/seeds/layout/exporter"
require_relative "comfortable_mexican_sofa/seeds/page/importer"
require_relative "comfortable_mexican_sofa/seeds/page/exporter"
require_relative "comfortable_mexican_sofa/seeds/snippet/importer"
require_relative "comfortable_mexican_sofa/seeds/snippet/exporter"
require_relative "comfortable_mexican_sofa/seeds/file/importer"
require_relative "comfortable_mexican_sofa/seeds/file/exporter"
require_relative "comfortable_mexican_sofa/extensions/acts_as_tree"
require_relative "comfortable_mexican_sofa/extensions/has_revisions"

require_relative "comfortable_mexican_sofa/content"

module ComfortableMexicanSofa

  class << self

    attr_writer :logger

    # Modify CMS configuration
    # Example:
    #   ComfortableMexicanSofa.configure do |config|
    #     config.cms_title = 'ComfortableMexicanSofa'
    #   end
    def configure
      yield configuration
    end

    # Accessor for ComfortableMexicanSofa::Configuration
    def configuration
      @configuration ||= Configuration.new
    end
    alias config configuration

    def logger
      @logger ||= Rails.logger
    end

  end

end
