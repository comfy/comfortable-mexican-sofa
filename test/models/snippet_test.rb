require_relative '../test_helper'

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
    assert_has_errors_on snippet, :site_id, :label, :identifier
  end
  
  def test_label_assignment
    snippet = cms_sites(:default).snippets.new(
      :identifier => 'test'
    )
    assert snippet.valid?
    assert_equal 'Test', snippet.label
  end
  
  def test_create
    assert_difference 'Cms::Snippet.count' do
      snippet = cms_sites(:default).snippets.create(
        :label      => 'Test Snippet',
        :identifier => 'test',
        :content    => 'Test Content'
      )
      assert_equal 'Test Snippet', snippet.label
      assert_equal 'test', snippet.identifier
      assert_equal 'Test Content', snippet.content
      assert_equal 1, snippet.position
    end
  end
  
  def test_update_forces_page_content_reload
    snippet = cms_snippets(:default)
    page = cms_pages(:default)
    assert_match snippet.content, page.content
    snippet.update_attributes(:content => 'new_snippet_content')
    page.reload
    assert_match /new_snippet_content/, page.content
  end
  
end
