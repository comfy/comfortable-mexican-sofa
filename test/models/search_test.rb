require_relative '../test_helper'

class CmsSearchTest < ActiveSupport::TestCase
  def test_search_label
    results = Comfy::Cms::Search.new(Comfy::Cms::Page, "Default").results
    assert_equal(Comfy::Cms::Page.find_by_label('Default Page'), results.first)
  end

  def test_order_label_then_meta
    create_page_block(child_page, "default child page", "meta_description")
    assert_equal(default_page, results_for("default")[0])
    assert_equal(child_page, results_for("default")[1])
  end

  def test_order_meta_then_h2
    create_page_block(default_page, "##Test\n##No Match")
    create_page_block(child_page, "test page", "meta_description")
    assert_equal(default_page, results_for("test")[1])
    assert_equal(child_page, results_for("test")[0])
  end

  def test_order_h2_then_h3
    create_page_block(default_page, "##Test\n###No Match")
    create_page_block(child_page, "##No Match\n###Test")
    assert_equal(default_page, results_for("test")[0])
    assert_equal(child_page, results_for("test")[1])
  end

  def test_order_h3_then_body_content
    create_page_block(default_page, "###Test")
    create_page_block(child_page, "Test")
    assert_equal(default_page, results_for("test")[0])
    assert_equal(child_page, results_for("test")[1])
  end

  def test_same_score_different_dates
    assert_equal(default_page, results_for("page")[0])
    assert_equal(child_page, results_for("page")[1])

    Timecop.freeze(Time.current - 1.day) do
      default_page.touch
    end

    @results = nil

    assert_equal(child_page, results_for("page")[0])
    assert_equal(default_page, results_for("page")[1])
  end

  private

  def create_page_block(page, content, identifier='content')
    page.blocks.create!(content: content, identifier: identifier )
  end

  def results_for(search_term)
    @results ||= Comfy::Cms::Search.new(Comfy::Cms::Page, search_term).results
  end

  def default_page
    Comfy::Cms::Page.find_by(label: "Default Page")
  end

  def child_page
    Comfy::Cms::Page.find_by(label: "Child Page")
  end
end
