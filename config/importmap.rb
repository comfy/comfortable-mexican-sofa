# frozen_string_literal: true

# Pin npm packages by running ./bin/importmap

pin "comfy/cms/application", to: "comfy/cms/application.js", preload: true

pin "@hotwired/turbo-rails", to: "turbo.min.js", preload: true
pin "@hotwired/stimulus", to: "stimulus.min.js", preload: true
pin "@hotwired/stimulus-loading", to: "stimulus-loading.js", preload: true

pin_all_from ComfortableMexicanSofa::Engine.root.join("app/javascript/comfy/cms/controllers"),
  under: "comfy/cms/controllers",
  to:    "comfy/cms/controllers"
