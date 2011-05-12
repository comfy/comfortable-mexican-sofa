require File.expand_path('../../test_helper', File.dirname(__FILE__))

class CmsSnippetTest < ActiveSupport::TestCase
  
  def test_fixtures_validity
    Cms::Snippet.all.each do |snippet|
      assert snippet.valid?, snippet.errors.full_messages.to_s
    end
  end
  
  def test_validations
    snippet = Cms::Snippet.new
    snippet.save
    assert snippet.invalid?
    assert_has_errors_on snippet, [:label, :slug]
  end
  
  def test_label_assignment
    snippet = cms_sites(:default).snippets.new(
      :slug   => 'test'
    )
    assert snippet.valid?
    assert_equal 'Test', snippet.label
  end
  
  def test_update_forces_page_content_reload
    snippet = cms_snippets(:default)
    page = cms_pages(:default)
    assert_match snippet.content, page.content
    snippet.update_attribute(:content, 'new_snippet_content')
    page.reload
    assert_match /new_snippet_content/, page.content
  end
  
end
