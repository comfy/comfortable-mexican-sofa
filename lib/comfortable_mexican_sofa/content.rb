# frozen_string_literal: true

module ComfortableMexicanSofa::Content
  # ...
end

require_relative "content/renderer"
require_relative "content/params_parser"
require_relative "content/tag"
require_relative "content/block"

require_relative "content/tags/fragment"

require_relative "content/tags/wysiwyg"
require_relative "content/tags/text"
require_relative "content/tags/textarea"
require_relative "content/tags/markdown"
require_relative "content/tags/datetime"
require_relative "content/tags/date"
require_relative "content/tags/number"
require_relative "content/tags/checkbox"
require_relative "content/tags/file"
require_relative "content/tags/files"

require_relative "content/tags/snippet"
require_relative "content/tags/asset"
require_relative "content/tags/file_link"
require_relative "content/tags/page_file_link"
require_relative "content/tags/helper"
require_relative "content/tags/partial"
require_relative "content/tags/template"
