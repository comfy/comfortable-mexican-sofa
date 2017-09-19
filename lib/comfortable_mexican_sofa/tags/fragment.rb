# Fragment tags
# Examples:
#   {% cms_fragment content %}
#   {% cms_fragment content, namespace: left %}
#   {% cms_fragment content, format: markdown %}
#   {% cms_fragment meta, format: text, render: false %}
#   {% cms_fragment header, format: file, partial: "path/to/partial", size: "200x100#"}
#
# Tags need the following:
# - name - corresponds to record on the database
# - namespace - basically a tab in the admin area. userful to group fragments
# - render (true(default) | false) - do we render via tag, or manually access fragment content later
# - format - controls how content is presented in admin area
#   - :textarea (default)
#   - :text
#   - :wysiwyg
#   - :markdown
#   - :datetime
#   - :date
#   - :file (this is a special one, can take more params)
#     - :multiple (true | false(default))
#     - :partial (path to the partial. partial will have all params from tag forwarded)
#     - :size (resize/crop string. need to explore what that means with active_storage)

require 'liquid/tag_with_params'

class FragmentTag < Liquid::TagWithParams

  attr_reader :name

  # Tag initialization. Need to probably validate params during init
  def initialize(_, _, context)
    super
    @name = @params[0]
    # raise self.parse_context.inspect
  end

  # Rendeting out fragment content. This is where we go and grab it from the DB
  def render(context)
    "hello: #{context.inspect}"
  end
end

Liquid::Template.register_tag('cms_fragment', FragmentTag)