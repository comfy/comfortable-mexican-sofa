# encoding: utf-8

require_relative '../../test_helper'

class CmsPageScopeTest < ActiveSupport::TestCase
  include FactoryGirl::Syntax::Methods

  # Pages with state 'published' should NOT be returned
  def test_page_with_title_like
    label1 = 'Financial well being: the employee view'
    label2 = 'Financial well being: the employer view'
    phrase = 'the employee view'
    
    FactoryGirl.create(:page, site: test_site, state: 'published', slug: 'slug', label: label1)
    FactoryGirl.create(:page, site: test_site, state: 'published', slug: 'slug', label: label2)

    assert_equal 1, test_site.pages.with_title_like(phrase).count
  end

  private

  # A site is used here to allow us to use factories
  # and keep them separate to fixture data
  def test_site
    @test_site ||= FactoryGirl.create(:site)
  end

end
