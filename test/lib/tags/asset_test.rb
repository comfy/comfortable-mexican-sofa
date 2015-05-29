require_relative '../../test_helper'

class AssetTagTest < ActiveSupport::TestCase

  def test_initialize_tag
    assert tag = ComfortableMexicanSofa::Tag::Asset.initialize_tag(
      comfy_cms_pages(:default), '{{ cms:asset:default:css:html_tag }}'
    )
    assert_equal 'default', tag.identifier
    assert_equal ['css', 'html_tag'], tag.params
  end

  def test_initialize_tag_failure
    [
      '{{cms:asset}}',
      '{{cms:not_asset:method_name}}',
      '{not_a_tag}'
    ].each do |tag_signature|
      assert_nil ComfortableMexicanSofa::Tag::Asset.initialize_tag(
        comfy_cms_pages(:default), tag_signature
      )
    end
  end

  def test_render_no_params
    tag = ComfortableMexicanSofa::Tag::Asset.initialize_tag(
      comfy_cms_pages(:default), '{{ cms:asset:default }}'
    )
    assert_equal '', tag.render
  end

  def test_render_for_css
    site = comfy_cms_sites(:default)
    layout = site.layouts.last

    tag = ComfortableMexicanSofa::Tag::Asset.initialize_tag(
      comfy_cms_pages(:default), "{{ cms:asset:#{layout.identifier}:css }}"
    )
    assert_equal "/cms-css/#{site.id}/#{layout.identifier}/#{layout.cache_buster}.css", tag.render

    tag = ComfortableMexicanSofa::Tag::Asset.initialize_tag(
      comfy_cms_pages(:default), "{{ cms:asset:#{layout.identifier}:css:html_tag }}"
    )
    assert_equal "<link href='/cms-css/#{site.id}/#{layout.identifier}/#{layout.cache_buster}.css' media='screen' rel='stylesheet' type='text/css' />", tag.render
  end

  def test_render_for_css_with_non_root_mount
    site = comfy_cms_sites(:default)
    layout = site.layouts.last

    ComfortableMexicanSofa.config.public_cms_path = '/custom'

    tag = ComfortableMexicanSofa::Tag::Asset.initialize_tag(
      comfy_cms_pages(:default), "{{ cms:asset:#{layout.identifier}:css }}"
    )
    assert_equal "/custom/cms-css/#{site.id}/#{layout.identifier}/#{layout.cache_buster}.css", tag.render

    tag = ComfortableMexicanSofa::Tag::Asset.initialize_tag(
      comfy_cms_pages(:default), "{{ cms:asset:#{layout.identifier}:css:html_tag }}"
    )
    assert_equal "<link href='/custom/cms-css/#{site.id}/#{layout.identifier}/#{layout.cache_buster}.css' media='screen' rel='stylesheet' type='text/css' />", tag.render
  end

  def test_render_for_js
    site = comfy_cms_sites(:default)
    layout = site.layouts.last

    tag = ComfortableMexicanSofa::Tag::Asset.initialize_tag(
      comfy_cms_pages(:default), "{{ cms:asset:#{layout.identifier}:js }}"
    )
    assert_equal "/cms-js/#{site.id}/#{layout.identifier}/#{layout.cache_buster}.js", tag.render

    tag = ComfortableMexicanSofa::Tag::Asset.initialize_tag(
      comfy_cms_pages(:default), "{{ cms:asset:#{layout.identifier}:js:html_tag }}"
    )
    assert_equal "<script src='/cms-js/#{site.id}/#{layout.identifier}/#{layout.cache_buster}.js' type='text/javascript'></script>", tag.render
  end

  def test_render_for_js_with_non_root_mount
    site = comfy_cms_sites(:default)
    layout = site.layouts.last

    ComfortableMexicanSofa.config.public_cms_path = '/custom'

    tag = ComfortableMexicanSofa::Tag::Asset.initialize_tag(
      comfy_cms_pages(:default), "{{ cms:asset:#{layout.identifier}:js }}"
    )
    assert_equal "/custom/cms-js/#{site.id}/#{layout.identifier}/#{layout.cache_buster}.js", tag.render

    tag = ComfortableMexicanSofa::Tag::Asset.initialize_tag(
      comfy_cms_pages(:default), "{{ cms:asset:#{layout.identifier}:js:html_tag }}"
    )
    assert_equal "<script src='/custom/cms-js/#{site.id}/#{layout.identifier}/#{layout.cache_buster}.js' type='text/javascript'></script>", tag.render
  end
end
