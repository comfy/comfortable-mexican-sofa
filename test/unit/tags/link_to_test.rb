require File.expand_path('../../test_helper', File.dirname(__FILE__))

class LinkToTest < ActiveSupport::TestCase
  
  def test_initialize_tag
    assert tag = ComfortableMexicanSofa::Tag::LinkTo.initialize_tag(
      cms_pages(:default), '{{ cms:link_to:label:slug }}'
    )
    assert_equal 'label', tag.label
    assert tag = ComfortableMexicanSofa::Tag::LinkTo.initialize_tag(
      cms_pages(:default), '{{ cms:link_to:Label with Spaces:slug }}'
    )
    assert_equal 'Label with Spaces', tag.label
    assert tag = ComfortableMexicanSofa::Tag::LinkTo.initialize_tag(
      cms_pages(:default), '{{cms:link_to:label:/path}}'
    )
    assert_equal 'label', tag.label
  end
  
  def test_initialize_tag_failure
    [
      '{{cms:link_to}}',
      '{{cms:not_link_to:label:slug}}',
      '{not_a_tag}'
    ].each do |tag_signature|
      assert_nil ComfortableMexicanSofa::Tag::LinkTo.initialize_tag(
        cms_pages(:default), tag_signature
      )
    end
  end
  
  def test_content_and_render
    tag = ComfortableMexicanSofa::Tag::LinkTo.initialize_tag(
      cms_pages(:default), '{{cms:link_to:My Link:}}'
    )
    assert_equal '<a href="/">My Link</a>', tag.content
    assert_equal '<a href="/">My Link</a>', tag.render
    
    tag = ComfortableMexicanSofa::Tag::LinkTo.initialize_tag(
      cms_pages(:default), '{{cms:link_to:My Link:child-page}}'
    )
    assert_equal '<a href="/child-page">My Link</a>', tag.content
    assert_equal '<a href="/child-page">My Link</a>', tag.render
    
    tag = ComfortableMexicanSofa::Tag::LinkTo.initialize_tag(
      cms_pages(:default), '{{cms:link_to:My Link:/path}}'
    )
    assert_equal '<a href="/path">My Link</a>', tag.content
    assert_equal '<a href="/path">My Link</a>', tag.render
    
    tag = ComfortableMexicanSofa::Tag::LinkTo.initialize_tag(
      cms_pages(:default), "{{cms:link_to:Does not exist:doesnot_exist}}"
    )
    assert_equal nil, tag.content
    assert_equal '', tag.render
  end
end