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
    tag = ComfortableMexicanSofa::Tag::Asset.initialize_tag(
      comfy_cms_pages(:default), '{{ cms:asset:default:css }}'
    )
    assert_equal "/cms-css/#{comfy_cms_sites(:default).id}/default.css", tag.render
    
    tag = ComfortableMexicanSofa::Tag::Asset.initialize_tag(
      comfy_cms_pages(:default), '{{ cms:asset:default:css:html_tag }}'
    )
    assert_equal "<link href='/cms-css/#{comfy_cms_sites(:default).id}/default.css' media='screen' rel='stylesheet' type='text/css' />", tag.render
  end

  def test_render_for_css_when_site_has_path
    tag = ComfortableMexicanSofa::Tag::Asset.initialize_tag(
      page_for_site_with_path('/foo'), '{{ cms:asset:default:css }}'
    )
    assert_equal "/cms-css/#{comfy_cms_sites(:default).id}/default.css?cms_path=/foo", tag.render
  end
  
  def test_render_for_js
    tag = ComfortableMexicanSofa::Tag::Asset.initialize_tag(
      comfy_cms_pages(:default), '{{ cms:asset:default:js }}'
    )
    assert_equal "/cms-js/#{comfy_cms_sites(:default).id}/default.js", tag.render
    
    tag = ComfortableMexicanSofa::Tag::Asset.initialize_tag(
      comfy_cms_pages(:default), '{{ cms:asset:default:js:html_tag }}'
    )
    assert_equal "<script src='/cms-js/#{comfy_cms_sites(:default).id}/default.js' type='text/javascript'></script>", tag.render
  end

  def test_render_for_js_when_site_has_path
    tag = ComfortableMexicanSofa::Tag::Asset.initialize_tag(
      page_for_site_with_path('/foo'), '{{ cms:asset:default:js }}'
    )
    assert_equal "/cms-js/#{comfy_cms_sites(:default).id}/default.js?cms_path=/foo", tag.render
  end

  def page_for_site_with_path(path)
    page = comfy_cms_pages(:default)
    page.site.update_attribute(:path, path)
    page
  end
end
