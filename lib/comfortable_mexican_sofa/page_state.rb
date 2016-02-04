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
      scheduled_offline: [
        { value: :schedule, label: 'Save Changes', data: SCHEDULE_DATA }
      ],
      scheduled_live: [
        { value: :schedule, label: 'Save Changes', data: SCHEDULE_DATA }
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
      scheduled_offline: [
        { value: :publish_changes, label: 'Publish now' },
      ],
      scheduled_live: [
        { value: :publish, label: 'Publish changes' },
        { value: :unpublish, label: 'Unpublish' },
      ]
    }.freeze

    CURRENT_STATUS = {
      published_being_edited: 'Published (being edited)',
      scheduled_offline: 'Scheduled',
      scheduled_live: 'Scheduled (live)'
    }

    def self.next_states_for(page)
      NEXT_STATE_OPTIONS[lookup_state_for(page)] || []
    end

    def self.main_state_for(page)
      MAIN_STATE[lookup_state_for(page)] || []
    end

    def self.current_status(page)
      CURRENT_STATUS[lookup_state_for(page)] || page.state.titleize
    end

    private

    def self.lookup_state_for(page)
      if page.state == 'scheduled'
        if page.scheduled_on <= Time.current
          :scheduled_live
        else
          :scheduled_offline
        end
      else
        page.state.to_sym
      end
    end
  end
end
