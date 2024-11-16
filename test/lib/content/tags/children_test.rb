# frozen_string_literal: true

require_relative '../../../test_helper'

class ContentTagsChildrenTest < ActiveSupport::TestCase
  setup do
    @site   = comfy_cms_sites(:default)
    @layout = comfy_cms_layouts(:default)
    @page   = comfy_cms_pages(:default)
    @parent = @site.pages.create!(layout: @layout, parent: @page, label: 'Parent', slug: 'parent')
    @child1 = @site.pages.create!(layout: @layout, parent: @parent, label: 'Child1', slug: 'child1')
    @child2 = @site.pages.create!(layout: @layout, parent: @parent, label: 'Child2', slug: 'child2')
    @child3 = @site.pages.create!(layout: @layout, parent: @parent, label: 'Child3', slug: 'child3')
    @child4 = @site.pages.create!(layout: @layout, parent: @parent, label: 'Child4', slug: 'child4')
    @child5 = @site.pages.create!(layout: @layout, parent: @parent, label: 'Child5', slug: 'child5', is_published: false)
  end

  def test_init
    tag = ComfortableMediaSurfer::Content::Tags::Children.new(
      context: @parent,
      params: []
    )
    assert_equal ({}), tag.locals
  end

  def test_init_with_style
    tag = ComfortableMediaSurfer::Content::Tags::Children.new(
      context: @parent,
      params: [{ 'style' => 'font-weight: bold' }]
    )
    assert_equal "<style>#children {font-weight: bold}</style>\n", tag.style
  end

  def test_render
    tag = ComfortableMediaSurfer::Content::Tags::Children.new(
      context: @parent,
      params: [{ 'style' => 'font-weight: bold' }]
    )
    html = "<style>#children {font-weight: bold}</style>\n\
<ul id=\"children\">\n\
  <li><a href=/parent/child1>Child1</a></li>\n\
  <li><a href=/parent/child2>Child2</a></li>\n\
  <li><a href=/parent/child3>Child3</a></li>\n\
  <li><a href=/parent/child4>Child4</a></li>\n\
</ul>"

    assert_equal html, tag.render
  end

  def test_render_with_exclusions
    tag = ComfortableMediaSurfer::Content::Tags::Children.new(
      context: @parent,
      params: [{ 'exclude' => 'child2,child3' }]
    )
    html = "<ul id=\"children\">\n\
  <li><a href=/parent/child1>Child1</a></li>\n\
  <li><a href=/parent/child4>Child4</a></li>\n\
</ul>"
    assert_equal html, tag.render
  end

  def test_render_with_no_kids
    tag = ComfortableMediaSurfer::Content::Tags::Children.new(
      context: @child4,
      params: []
    )
    assert_equal '', tag.render
  end
end
