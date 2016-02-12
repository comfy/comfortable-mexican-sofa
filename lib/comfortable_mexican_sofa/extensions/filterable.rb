module ComfortableMexicanSofa::Filterable

  extend ActiveSupport::Concern

  module ClassMethods

    def filter(filtering_params)
      results = self.where(nil)
      filtering_params.each do |key, value|
        # States map to named scopes
        if key == 'status'
          results = results.public_send(value) if value.present?

        # Other keys map directly to columns
        else
          results = results.public_send(key, value) if value.present?
        end
      end
      results
    end

  end
end

ActiveRecord::Base.send :include, ComfortableMexicanSofa::Filterable
