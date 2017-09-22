class Fragment

  def initialize(page, name, params = {})
    @page = page
    @name = name
  end

  def fragment
    page.blocks.detect{|f| f.identifier == @name} ||
      page.blocks.build(identifier: @name)
  end

  def content
    fragment.content
  end

  def render
    content
  end

end