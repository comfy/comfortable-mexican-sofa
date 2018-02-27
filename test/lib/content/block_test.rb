# frozen_string_literal: true

require_relative "../../test_helper"

class ContentBlockTest < ActiveSupport::TestCase

  class TestBlockTag < ComfortableMexicanSofa::Content::Block
    # ...
  end

  setup do
    ComfortableMexicanSofa::Content::Renderer.register_tag(:test_block, TestBlockTag)
  end

  teardown do
    ComfortableMexicanSofa::Content::Renderer.tags.delete("test_block")
  end

  # -- Tests -------------------------------------------------------------------

  def test_block_tag_nodes
    block = TestBlockTag.new(context: nil)
    assert_equal [], block.nodes
    block.nodes << "text"
    assert_equal ["text"], block.nodes
  end

end
