require 'comfortable_mexican_sofa'
require 'rails'
require 'paperclip'
require 'active_link_to'
require 'mime/types'

module ComfortableMexicanSofa
  class Engine < ::Rails::Engine
    initializer 'comfortable-mexican-sofa:check_migrations' do
      ComfortableMexicanSofa::Version.check!
    end
  end
end

