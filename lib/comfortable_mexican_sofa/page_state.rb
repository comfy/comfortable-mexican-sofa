module ComfortableMexicanSofa
  class PageState
    SCHEDULE_DATA = {
      dough_dialog_trigger: :scheduler,
      dough_component: 'Dialog Scheduler'
    }

    MAIN_STATE = {
      unsaved: [
        { value: :save_unsaved, label: 'Save' }
      ],
      draft: [
        { value: :save_changes, label: 'Save Changes' }
      ],
      published: [
        { value: :save_changes_as_draft, label: 'Save changes as draft' }
      ],
      published_being_edited: [
        { value: :save_draft_changes, label: 'Save draft changes' }
      ],
      unpublished: [
        { value: :save_changes, label: 'Save Changes' }
      ],
      redirected: [
        { value: :re_publish, label: 'Republish' }
      ],
      scheduled: [
        { value: :schedule, label: 'Scheduled', data: SCHEDULE_DATA }
      ]
    }

    NEXT_STATE_OPTIONS = {
      draft: [
        { value: :publish, label: 'Publish' },
        { value: :schedule, label: 'Schedule', data: SCHEDULE_DATA },
        { value: :delete_page, label: 'Delete',
          data: { confirm: 'Are you sure?' } }
      ],
      published: [
        { value: :publish_changes, label: 'Publish changes' },
        { value: :schedule, label: 'Schedule', data: SCHEDULE_DATA },
        { value: :unpublish, label: 'Unpublish' }
      ],
      published_being_edited: [
        { value: :schedule, label: 'Schedule', data: SCHEDULE_DATA },
        { value: :publish_changes, label: 'Publish changes' }
      ],
      scheduled: [
        { value: :publish_changes, label: 'Publish changes' }
      ]
    }.freeze

    CURRENT_STATUS = {
      published_being_edited: 'Published (being edited)'
    }

    def self.next_states_for(state)
      NEXT_STATE_OPTIONS[state] || []
    end

    def self.main_state_for(state)
      MAIN_STATE[state] || []
    end

    def self.current_status(state)
      CURRENT_STATUS[state] || state.to_s.titleize
    end
  end
end
