require_relative "../test_helper"


class CmsFileTest < ActiveSupport::TestCase

  def test_fixtures_validity
    Comfy::Cms::File.all.each do |file|
      assert file.valid?, file.errors.full_messages.to_s
    end
  end

  def test_validations
    file = Comfy::Cms::File.new
    assert file.invalid?
    assert_has_errors_on file, :site
  end

  def test_creation
    assert_difference "Comfy::Cms::File.count" do
      file = comfy_cms_sites(:default).files.create(
        description: "test file"
      )
      assert_equal 1, file.position
    end
  end
end
