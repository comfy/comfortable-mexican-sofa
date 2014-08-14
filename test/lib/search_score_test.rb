require_relative '../test_helper'

class SearchScoreTest < ActiveSupport::TestCase

  def test_label_score
    assert_equal 100, search_score("term", "label term")
  end

  def test_meta_description_score
    assert_equal 35, search_score("term", "no match", [{identifier: 'meta_description', content: "term"}])
  end

  def test_block_score
    assert_equal 1, search_score("term", "no match", [{identifier: 'content', content: "term"}])
  end

  def test_heading_2_score
    assert_equal 30, search_score("term", "no match", [{identifier: 'content', content: "##term"}])
  end

  def test_heading_3_score
    assert_equal 20, search_score("term", "no match", [{identifier: 'content', content: "###term"}])
  end

  def test_combination
    assert_equal 185, search_score("term", "term", [
      {identifier: 'content', content: "##term\n###term"},
      {identifier: 'meta_description', content: "term"}
      ])
  end

  private

  def search_score(term, label, blocks=[])
    ComfortableMexicanSofa::SearchScore.new(term, label, blocks).score
  end
end
