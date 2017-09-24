module ComfortableMexicanSofa::Content
  # ...
end

require_relative 'content/template'
require_relative 'content/params_parser'
require_relative 'content/tag'
require_relative 'content/block'

Dir.glob(File.expand_path('content/tags/*.rb', File.dirname(__FILE__))).each do |path|
  require_relative path
end
