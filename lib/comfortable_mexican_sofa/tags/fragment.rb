# Fragment tags need the following:
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

class FragmentTag < Liquid::TagWithParams

  # Tag initialization. Need to probably validate params during init
  def initialize(_, _, _)
    super
  end

  # Rendeting out fragment content. This is where we go and grab it from the DB
  def render(_context)
    "hello"
  end
end

Liquid::Template.register_tag('cms_fragment', FragmentTag)