module TestApp
  class Application < Rails::Application
    # Ensuring that all engines and their routes get loaded before this app.
    # This is to prevent Comfy globbing route from killing appended routes.
    config.railties_order = [:all, :main_app]
  end
end
