# frozen_string_literal: true

module ComfortableMediaSurfer
  class Error < StandardError
  end

  class MissingSite < ComfortableMediaSurfer::Error
    def initialize(identifier)
      super("Cannot find CMS Site with identifier: #{identifier}")
    end
  end

  class MissingLayout < ComfortableMediaSurfer::Error
    def initialize(identifier)
      super("Cannot find CMS Layout with identifier: #{identifier}")
    end
  end

  class MissingPage < ComfortableMediaSurfer::Error
    def initialize(path)
      super("Cannot find CMS Page at #{path}")
    end
  end
end
