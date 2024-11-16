# frozen_string_literal: true

# Loading engine only if this is not a standalone installation
unless defined? ComfortableMediaSurfer::Application
  require_relative 'comfortable_media_surfer/engine'
end

require_relative 'comfortable_media_surfer/version'
require_relative 'comfortable_media_surfer/error'
require_relative 'comfortable_media_surfer/configuration'
require_relative 'comfortable_media_surfer/routing'
require_relative 'comfortable_media_surfer/access_control/admin_authentication'
require_relative 'comfortable_media_surfer/access_control/admin_authorization'
require_relative 'comfortable_media_surfer/access_control/public_authentication'
require_relative 'comfortable_media_surfer/access_control/public_authorization'
require_relative 'comfortable_media_surfer/render_methods'
require_relative 'comfortable_media_surfer/view_hooks'
require_relative 'comfortable_media_surfer/form_builder'
require_relative 'comfortable_media_surfer/seeds'
require_relative 'comfortable_media_surfer/seeds/layout/importer'
require_relative 'comfortable_media_surfer/seeds/layout/exporter'
require_relative 'comfortable_media_surfer/seeds/page/importer'
require_relative 'comfortable_media_surfer/seeds/page/exporter'
require_relative 'comfortable_media_surfer/seeds/snippet/importer'
require_relative 'comfortable_media_surfer/seeds/snippet/exporter'
require_relative 'comfortable_media_surfer/seeds/file/importer'
require_relative 'comfortable_media_surfer/seeds/file/exporter'
require_relative 'comfortable_media_surfer/content'
require_relative 'comfortable_media_surfer/extensions'

module ComfortableMediaSurfer
  Version = ComfortableMediaSurfer::VERSION

  class << self
    attr_writer :logger

    # Modify CMS configuration
    # Example:
    #   ComfortableMediaSurfer.configure do |config|
    #     config.cms_title = 'ComfortableMediaSurfer'
    #   end
    def configure
      yield configuration
    end

    # Accessor for ComfortableMediaSurfer::Configuration
    def configuration
      @configuration ||= Configuration.new
    end
    alias config configuration

    def logger
      @logger ||= Rails.logger
    end
  end
end
