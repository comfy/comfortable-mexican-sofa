class ComfortableMexicanSofa::Base < ActiveRecord::Base
  self.abstract_class = true

  def self.establish_connection
    if ComfortableMexicanSofa.config.database_config && !Rails.env.test?
      super "#{ComfortableMexicanSofa.config.database_config}_#{Rails.env}"
    end
  end
end