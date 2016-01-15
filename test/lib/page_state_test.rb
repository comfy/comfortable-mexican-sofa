require_relative '../test_helper'

class PageStateTest < ActiveSupport::TestCase
  def test_unsaved
    assert_equal [:save_unsaved], main_state_for(:unsaved).map { |state| state[:value] }
  end

  def test_draft
    assert_equal [:publish, :schedule, :delete_page], page_states_for(:draft).map { |state| state[:value] }
  end

  def test_published
    assert_equal [:publish_changes, :schedule, :unpublish], page_states_for(:published).map { |state| state[:value] }
  end

  def test_publish_being_edited_current_status
    assert_equal 'Published (being edited)', page_current_status(:published_being_edited)
  end

  def test_draft_current_status
    assert_equal 'Draft', page_current_status(:draft)
  end

  def test_unsaved_current_status
    assert_equal 'Unsaved', page_current_status(:unsaved)
  end

  private

  def page_states_for(state)
    page_object = stub(state: state.to_s)
    ComfortableMexicanSofa::PageState.next_states_for(page_object)
  end

  def main_state_for(state)
    page_object = stub(state: state.to_s)
    ComfortableMexicanSofa::PageState.main_state_for(page_object)
  end

  def page_current_status(state)
    page_object = stub(state: state.to_s)
    ComfortableMexicanSofa::PageState.current_status(page_object)
  end
end
