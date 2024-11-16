# frozen_string_literal: true

require_relative 'boot'

require 'rails/all'

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)

module ComfortableMediaSurfer
  class Application < Rails::Application
    # Load defaults based on Rails major/minor version
    config.load_defaults Rails.version.scan(%r{^\d+\.\d+}).first.to_f

    # Rails 7.1 compatibility - See config/initializers/new_framework_defaults_7_1.rb
    if Gem::Version.new(Rails.version) >= Gem::Version.new('7.1.0')
      config.active_record.default_column_serializer = YAML
      config.active_record.before_committed_on_all_records = false
      config.active_record.commit_transaction_on_non_local_return = false
      config.active_record.run_after_transaction_callbacks_in_order_defined = false
      config.active_support.message_serializer = :json
      config.active_record.run_commit_callbacks_on_first_saved_instances_in_transaction = true
      # config.active_record.allow_deprecated_singular_associations_name = true
      # config.active_support.raise_on_invalid_cache_expiration_time = false
      # config.active_record.sqlite3_adapter_strict_strings_by_default = false
      # config.active_support.cache_format_version = 7.0
      # Please, add to the `ignore` list any other `lib` subdirectories that do
      # not contain `.rb` files, or that should not be reloaded or eager loaded.
      # Common ones are `templates`, `generators`, or `middleware`, for example.
      config.add_autoload_paths_to_load_path = false
      config.autoload_lib(ignore: %w[generators])
    end

    # Making sure we don't load our dev routes as part of the engine
    config.paths['config/routes.rb'] << 'config/cms_routes.rb'

    # Configuration for the application, engines, and railties goes here.
    #
    # These settings can be overridden in specific environments using the files
    # in config/environments, which are processed later.
    #
    # config.time_zone = "Central Time (US & Canada)"
    # config.eager_load_paths << Rails.root.join("extras")
    # Ensuring that all ActiveStorage routes are loaded before out globbing route.
    config.railties_order = [ActiveStorage::Engine, :main_app, :all]

    config.i18n.enforce_available_locales = true

    config.active_record.yaml_column_permitted_classes = [
      Symbol,
      Date,
      Time,
      ActiveSupport::TimeWithZone,
      ActiveSupport::TimeZone,
      ActiveSupport::SafeBuffer
    ]
  end
end
