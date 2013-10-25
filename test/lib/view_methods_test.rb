require_relative '../test_helper'

class ViewMethodsTest < ActionView::TestCase

  include ComfortableMexicanSofa::ViewMethods

  class ::HelpersTestController < ActionController::Base
    helper { def hello; 'hello' end }

    def test_cms_snippet_content
      render :inline => '<%= cms_snippet_content(:default) %>'
    end

    def test_cms_page_block_content
      @cms_page = Cms::Page.root
      render :inline => '<%= cms_page_block_content(:default_field_text) %>'
    end
    
    def test_cms_snippet_with_default_content_block
      render :inline => '<%= cms_snippet_content(:nonexistent_snippet) do %>
                           Some content <b>here</b>.
                         <% end %>'
    end

    def test_cms_page_content
      @cms_page = Cms::Page.root
      render :inline => '<%= cms_page_content(:default_field_text) %>'
    end
  end

  class ::HelperTestMailer < ActionMailer::Base
    def test_cms_snippet_content_in_mailer
      mail(:to => "a@test.com", :subject => "test") do |format|
        format.text { render :inline => '<%= cms_snippet_content(:default) %>' }
      end
    end
  end

  # Simulating a call and getting resulting output
  def action_result(action)
    HelpersTestController.action(action).call(ActionController::TestRequest.new.env).last.body
  end

  def mail_result(mail)
    HelperTestMailer.send(mail).body.to_s
  end

  def test_cms_snippet_content_in_mailer
    assert_equal 'default_snippet_content', mail_result('test_cms_snippet_content_in_mailer')
  end

  def test_cms_snippet_content
    assert_equal 'default_snippet_content', action_result('test_cms_snippet_content')
  end
  
  def test_cms_snippet_content_missing
    Cms::Snippet.delete_all
    assert_equal '', action_result('test_cms_snippet_content')
  end

  def test_cms_snippet_content_with_tags
    cms_snippets(:default).update_columns(:content => '{{cms:helper:hello}}')
    assert_equal 'hello', action_result('test_cms_snippet_content')
  end

  def test_cms_snippet_content_with_file_tag
    cms_snippets(:default).update_column(:content, '{{cms:file:sample.jpg}}')
    assert_equal cms_files(:default).file.url, action_result('test_cms_snippet_content')
  end

  def test_cms_page_block_content
    assert_equal 'default_field_text_content', action_result('test_cms_page_block_content')
  end
  
  def test_cms_page_block_content_missing
    Cms::Block.delete_all
    assert_equal '', action_result('test_cms_page_block_content')
  end

  def test_cms_page_files
    page = cms_pages(:default)
    page.layout.update_column(:content, '{{cms:page_files:files}}')
    page.update_attributes!(
      :blocks_attributes => [
        {
          :identifier => 'files',
          :content    => [
            fixture_file_upload('files/image.jpg', "image/jpeg"),
            fixture_file_upload('files/image.gif', "image/gif")
          ]
        }
      ]
    )
    assert_equal page.blocks.find_by_identifier('files').files, cms_page_files(:files, page)
  end

  def test_cms_snippet_with_default_content_block_displays_content
    assert_equal 'Some content <b>here</b>.',
      action_result('test_cms_snippet_with_default_content_block').strip
  end

  def test_cms_snippet_with_default_content_creates_snippet
    assert_nil Cms::Snippet.find_by_identifier('nonexistent_snippet')
    action_result('test_cms_snippet_with_default_content_block')
    assert_not_nil Cms::Snippet.find_by_identifier('nonexistent_snippet')
  end

  def test_cms_snippet_with_default_content_shows_stored_snippet_if_present
    cms_snippets(:default).update_attribute(:identifier, 'nonexistent_snippet')
    assert_equal 'default_snippet_content',
      action_result('test_cms_snippet_with_default_content_block')
  end

  def test_cms_snippet_content_with_irb
    cms_snippets(:default).update_column(:content, '<%= 1+1+1+1+1 %>')
    assert_equal "&lt;%= 1+1+1+1+1 %&gt;", action_result('test_cms_snippet_content')
  end


  def test_cms_page_content
    assert_equal 'default_field_text_content', action_result('test_cms_page_content')
  end
  
  def test_cms_page_content_missing
    Cms::Page.delete_all
    assert_equal '', action_result('test_cms_page_content')
  end

  def test_cms_page_content_with_tags
    cms_blocks(:default_field_text).update_column(:content, '{{cms:helper:hello}}')
    assert_equal 'hello', action_result('test_cms_page_content')
  end

  def test_cms_page_content_with_files
    page = cms_pages(:default)
    page.layout.update_column(:content, '{{cms:page_file:file}} {{cms:page_files:files}}')
    page.update_attributes!(
      :blocks_attributes => [
        { :identifier => 'file',
          :content    => fixture_file_upload('files/image.jpg', "image/jpeg") },
        { :identifier => 'files',
          :content    => [fixture_file_upload('files/image.jpg', "image/jpeg"),
                          fixture_file_upload('files/image.gif', "image/gif")] }
      ]
    )
    assert_equal page.blocks.find_by_identifier('file').files.first, cms_page_content(:file, page)
    assert_equal page.blocks.find_by_identifier('files').files, cms_page_content(:files, page)
  end

  def test_cms_page_content_with_irb
    cms_blocks(:default_field_text).update_column(:content, '<%= 1+1+1+1+1 %>')
    assert_equal "&lt;%= 1+1+1+1+1 %&gt;", action_result('test_cms_page_content')
  end

end
