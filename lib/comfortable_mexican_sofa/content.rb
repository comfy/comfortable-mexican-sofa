# frozen_string_literal: true

module ComfortableMexicanSofa::Content
  # ...
end

require_relative "content/renderer"
require_relative "content/params_parser"
require_relative "content/tag"
require_relative "content/fragment_tag"

require_relative "content/tag/text_tag"
require_relative "content/tag/textarea_tag"
require_relative "content/tag/wysiwyg_tag"
require_relative "content/tag/number_tag"
require_relative "content/tag/markdown_tag"
require_relative "content/tag/datetime_tag"
require_relative "content/tag/date_tag"
require_relative "content/tag/checkbox_tag"
require_relative "content/tag/file_content_mixin"
require_relative "content/tag/files_tag"
require_relative "content/tag/file_tag"
require_relative "content/tag/page_file_link_tag"
require_relative "content/tag/site_file_link_tag"
require_relative "content/tag/snippet_tag"
require_relative "content/tag/layout_asset_tag"
require_relative "content/tag/render_template_tag"


#
#
#
# require_relative "content/tags/file_link"
# require_relative "content/tags/page_file_link"
# require_relative "content/tags/helper"
# require_relative "content/tags/partial"
# require_relative "content/tags/template"
