require_relative '../test_helper'

class PageStateTest < ActiveSupport::TestCase

  def test_unsaved
    assert_equal [:save_unsaved], page_state_for(:unsaved).map {|state| state[:value]}
  end

  def test_draft
    assert_equal [:save_changes, :publish, :delete_page], page_state_for(:draft).map {|state| state[:value]}
  end

  def test_published
    assert_equal [:save_changes_as_draft, :publish_changes, :unpublish], page_state_for(:published).map {|state| state[:value]}
  end

  def test_publish_being_edited_current_status
    assert_equal "Published (being edited)", page_current_status(:published_being_edited)
  end

  def test_draft_current_status
    assert_equal "Draft", page_current_status(:draft)
  end

  def test_unsaved_current_status
    assert_equal "Unsaved", page_current_status(:unsaved)
  end

  private

  def page_state_for(state)
    ComfortableMexicanSofa::PageState.next_states_for(state)
  end

  def page_current_status(state)
    ComfortableMexicanSofa::PageState.current_status(state)
  end
end
