require File.dirname(__FILE__) + '/../test_helper'

class CmsPageContentTest < ActiveSupport::TestCase
  
  def test_initialization_of_content_objects
    content = %(
      <html><body class='awesome'>
        <cms:page:header/>
        <div class='main'>
          <cms:page:content/>
        </div>
        <cms:page:footer/>
      </body></html>
    )
    CmsPageContent.initialize_content_objects(content)
  end
  
end
