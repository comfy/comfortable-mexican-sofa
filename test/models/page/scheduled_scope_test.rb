# encoding: utf-8

require_relative '../../test_helper'

class CmsPageScopeTest < ActiveSupport::TestCase
  include FactoryGirl::Syntax::Methods

  # Pages with state 'published' should NOT be returned
  def test_page_with_state_published
    FactoryGirl.create(:page, site: test_site, state: 'published')
    assert_equal 0, test_site.pages.scheduled.count
  end

  # Pages with state 'published_being_edited' should NOT be returned
  def test_page_with_state_published_being_edited
    FactoryGirl.create(:page, site: test_site, state: 'published_being_edited')
    assert_equal 0, test_site.pages.scheduled.count
  end

  # Pages with state 'scheduled' and timestamp in the past should not be returned
  def test_page_with_state_scheduled_and_timestamp_in_past
    FactoryGirl.create(:page, site: test_site, state: 'scheduled', scheduled_on: 1.minute.ago)
    assert_equal 0, test_site.pages.scheduled.count
  end

  # Pages with state 'scheduled' and timestamp in the future, but also an active_revision
  # should be returned
  def test_page_with_state_scheduled_and_timestamp_in_the_future_and_active_revision
    revision = FactoryGirl.create(:revision)
    FactoryGirl.create(:page, site: test_site, state: 'scheduled', scheduled_on: 1.minute.from_now, active_revision: revision)
    assert_equal 1, test_site.pages.scheduled.count
  end

  # Pages with state 'scheduled' and timestamp in the future, and no active_revision
  # should NOT be returned (or created in the first place)
  def test_page_with_state_scheduled_and_timestamp_in_the_future_and_no_active_revision
    FactoryGirl.create(:page, site: test_site, state: 'scheduled', scheduled_on: 1.minute.from_now)
    assert_equal 0, test_site.pages.scheduled.count
  end

  private

  # A site is used here to allow us to use factories
  # and keep them separate to fixture data
  def test_site
    @test_site ||= FactoryGirl.create(:site)
  end

end
