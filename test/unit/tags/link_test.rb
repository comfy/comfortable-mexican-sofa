require File.expand_path('../../test_helper', File.dirname(__FILE__))

class LinkTagTest < ActiveSupport::TestCase

  def test_initialize_tag
    assert tag = ComfortableMexicanSofa::Tag::Link.initialize_tag(
      cms_pages(:default), '{{ cms:link:/ }}'
    )

    assert_equal 'http://test.host/', tag.content
  end

  def test_page_not_found
    assert tag = ComfortableMexicanSofa::Tag::Link.initialize_tag(
      cms_pages(:default), '{{ cms:link:not-found }}'
    )

    assert_equal "", tag.content
  end

  def test_page_with_a_real_name
    assert tag = ComfortableMexicanSofa::Tag::Link.initialize_tag(
      cms_pages(:default), '{{ cms:link:child-page }}'
    )

    assert_equal "http://test.host/child-page", tag.content
  end

end
