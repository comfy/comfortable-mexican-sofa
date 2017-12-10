require_relative "../../../test_helper"

class ContentTagsHelperTest < ActiveSupport::TestCase

  def test_init
    tag = ComfortableMexicanSofa::Content::Tag::Helper.new(@page, "helper_method")
    assert_equal "helper_method", tag.method_name
    assert_equal [], tag.params
  end

  def test_init_with_params
    tag = ComfortableMexicanSofa::Content::Tag::Helper.new(@page, "helper_method, param, key: val")
    assert_equal "helper_method", tag.method_name
    assert_equal ["param", { "key" => "val" }], tag.params
  end

  def test_init_without_method_name
    message = "Missing method name for helper tag"
    assert_exception_raised ComfortableMexicanSofa::Content::Tag::Error, message do
      ComfortableMexicanSofa::Content::Tag::Helper.new(@page, "")
    end
  end

  def test_content
    tag = ComfortableMexicanSofa::Content::Tag::Helper.new(@page, "method_name, param, key: val")
    assert_equal "<%= method_name(\"param\",{\"key\"=>\"val\"}) %>", tag.content
  end

  def test_render
    tag = ComfortableMexicanSofa::Content::Tag::Helper.new(@page, "method_name, param, key: val")
    assert_equal "<%= method_name(\"param\",{\"key\"=>\"val\"}) %>", tag.render
  end

  def test_render_with_whitelist
    ComfortableMexicanSofa.config.allowed_helpers = %i[tester eval]
    tag = ComfortableMexicanSofa::Content::Tag::Helper.new(@page, "tester")
    assert_equal "<%= tester() %>", tag.render

    tag = ComfortableMexicanSofa::Content::Tag::Helper.new(@page, "eval")
    assert_equal "<%= eval() %>", tag.render

    tag = ComfortableMexicanSofa::Content::Tag::Helper.new(@page, "not_whitelisted")
    assert_nil tag.render
  end

  def test_render_with_blacklist
    ComfortableMexicanSofa::Content::Tag::Helper::BLACKLIST.each do |method|
      tag = ComfortableMexicanSofa::Content::Tag::Helper.new(@page, method)
      assert_nil tag.render
    end
  end

end
