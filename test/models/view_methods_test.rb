require_relative '../test_helper'

class ViewMethodsTest < ActionView::TestCase
  
  include ComfortableMexicanSofa::ViewMethods
  
  class ::HelpersTestController < ActionController::Base
    helper { def hello; 'hello' end }

    def test_cms_snippet_content
      render :inline => '<%= cms_snippet_content(:default) %>'
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
  
  def test_cms_snippet_content_with_tags
    cms_snippets(:default).update_columns(:content => '{{cms:helper:hello}}')
    assert_equal 'hello', action_result('test_cms_snippet_content')
  end
  
  def test_cms_snippet_content_with_file_tag
    cms_snippets(:default).update_column(:content, '{{cms:file:sample.jpg}}')
    assert_equal cms_files(:default).file.url, action_result('test_cms_snippet_content')
  end
  
  def test_cms_page_content
    assert_equal 'default_field_text_content', action_result('test_cms_page_content')
  end
  
  def test_cms_page_content_with_tags
    cms_blocks(:default_field_text).update_column(:content, '{{cms:helper:hello}}')
    assert_equal 'hello', action_result('test_cms_page_content')
  end
  
  def test_cms_page_content_with_files
    page = cms_pages(:default)
    page.layout.update_column(:content, '{{cms:page_file:file}} {{cms:page_files:files}}')
    page.update_attributes!(
      :page_content_attributes => {
        :id => page.page_content.id,
        :blocks_attributes => [
          { :identifier => 'file',
            :content    => fixture_file_upload('files/image.jpg', "image/jpeg") },
          { :identifier => 'files',
            :content    => [fixture_file_upload('files/image.jpg', "image/jpeg"),
                            fixture_file_upload('files/image.gif', "image/gif")] }
        ]
      }
    )
    assert_equal page.page_content.blocks.find_by_identifier('file').files.first, cms_page_content(:file, page)
    assert_equal page.page_content.blocks.find_by_identifier('files').files, cms_page_content(:files, page)
  end
  
end