# frozen_string_literal: true

module ComfortableMexicanSofa::Content
  # ...
end

require_relative "content/renderer"
require_relative "content/params_parser"
require_relative "content/tag"
require_relative "content/fragment_tag"

require_relative "content/tags/text_tag"
require_relative "content/tags/textarea_tag"
require_relative "content/tags/wysiwyg_tag"
require_relative "content/tags/number_tag"
require_relative "content/tags/markdown_tag"
require_relative "content/tags/datetime_tag"
require_relative "content/tags/date_tag"
require_relative "content/tags/checkbox_tag"


#
# require_relative "content/tags/file"
# require_relative "content/tags/files"
#
# require_relative "content/tags/snippet"
# require_relative "content/tags/asset"
# require_relative "content/tags/file_link"
# require_relative "content/tags/page_file_link"
# require_relative "content/tags/helper"
# require_relative "content/tags/partial"
# require_relative "content/tags/template"
