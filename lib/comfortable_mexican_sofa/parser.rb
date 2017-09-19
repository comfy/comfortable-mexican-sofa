class ComfortableMexicanSofa::Parser

  def initialize(page)
    @page = page
    self
  end

  # What does it even do?
  # - Grab layout of the page
  # - parse tags on the layout
  # -  if there's parent layout and it has {% cms_fragment content %} we need to replace
  #    that node with parsed content of the current layout. It can be nested infinitely.
  # - need to collect page fragments. Meaning we're expanding cms_fragment, cms_snippet tags
  #   as their content might have more tags in them.
  def parse
    return "" unless @page.layout
    parse_layout(@page.layout)
  end

  def parse_layout(layout)
    puts "PARSING LAYOUT"

    t = Liquid::Template.parse(layout.content, page: @page)

    nodelist = t.root.nodelist

    if parent = layout.parent
      puts "MERGING NODES!"

      parent_nodelist = parse_layout(parent)
      nodelist = parent_nodelist.map{|node| node.is_a?(FragmentTag) && node.name == "content" ? nodelist : node}.flatten
    end

    return nodelist
  end


end