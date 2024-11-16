# frozen_string_literal: true

# We can't have this in config/routes.rb as they will get pulled in into parent
# application automatically. We want user to manually place them.
ComfortableMediaSurfer::Application.routes.draw do
  comfy_route :cms_admin
  comfy_route :cms
end
