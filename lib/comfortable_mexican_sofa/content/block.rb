# frozen_string_literal: true

# wtf does this mean
# it means that all nodes between this must be moved into here
# {{cms:block}} some content {{cms:end_block}}
class ComfortableMexicanSofa::Content::Block < ComfortableMexicanSofa::Content::Tag

  attr_writer :nodes

  def nodes
    @nodes ||= []
  end

end
