require_relative '../test_helper'

class PageStateTest < ActiveSupport::TestCase
  def test_unsaved
    assert_equal [:save_unsaved], main_state_for(:unsaved).map { |state| state[:value] }
  end

  def test_draft
    assert_equal [:save_changes], main_state_for(:draft).map { |state| state[:value] }
    assert_equal [:publish, :schedule, :delete_page], page_states_for(:draft).map { |state| state[:value] }
  end

  def test_published
    assert_equal [:save_changes_as_draft], main_state_for(:published).map { |state| state[:value] }
    assert_equal [:publish_changes, :schedule, :unpublish], page_states_for(:published).map { |state| state[:value] }
  end

  def test_scheduled_offline
    assert_equal [:schedule], main_state_for(:scheduled, scheduled_on: 1.minute.from_now).map { |state| state[:value] }
    assert_equal [:publish_changes], page_states_for(:scheduled, scheduled_on: 1.minute.from_now).map { |state| state[:value] }
  end

  def test_scheduled_live
    assert_equal [:schedule], main_state_for(:scheduled, scheduled_on: 1.minute.ago).map { |state| state[:value] }
    assert_equal [:publish, :unpublish], page_states_for(:scheduled, scheduled_on: 1.minute.ago).map { |state| state[:value] }
  end

  def test_publish_being_edited_current_status
    assert_equal 'Published (being edited)', page_current_status(:published_being_edited)
  end

  def test_sheduled_offline_current_status
    assert_equal 'Scheduled', page_current_status(:scheduled, scheduled_on: 1.minute.from_now)
  end

  def test_sheduled_live_current_status
    assert_equal 'Scheduled (live)', page_current_status(:scheduled, scheduled_on: 1.minute.ago)
  end

  def test_draft_current_status
    assert_equal 'Draft', page_current_status(:draft)
  end

  def test_unsaved_current_status
    assert_equal 'Unsaved', page_current_status(:unsaved)
  end

  private

  def page_states_for(state, options = {})
    page_object = page_double(state, options)
    ComfortableMexicanSofa::PageState.next_states_for(page_object)
  end

  def main_state_for(state, options = {})
    page_object = page_double(state, options)
    ComfortableMexicanSofa::PageState.main_state_for(page_object)
  end

  def page_current_status(state, options = {})
    page_object = page_double(state, options)
    ComfortableMexicanSofa::PageState.current_status(page_object)
  end

  def page_double(state, options = {})
    stub(state: state.to_s).tap do |page_object|
      page_object.stubs(:scheduled_on).returns(options[:scheduled_on]) if options[:scheduled_on]
    end
  end
end
