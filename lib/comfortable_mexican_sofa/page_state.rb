module ComfortableMexicanSofa
  class PageState

    NEXT_STATE_OPTIONS = {
      unsaved: [
        {value: :save_unsaved, label: "Save" }
      ],
      draft: [
        {value: :save_changes, label: "Save Changes" },
        {value: :publish, label: "Publish" },
        {value: :delete_page, label: "Delete", data: {confirm: "Are you sure?" } },
      ],
      published: [
        {value: :save_changes_as_draft, label: "Save changes as draft" },
        {value: :publish_changes, label: "Publish changes" },
        {value: :unpublish, label: "Unpublish" }
      ],
      published_being_edited: [
        {value: :save_draft_changes, label: "Save draft changes" },
        {value: :publish_changes, label: "Publish changes" }
      ],
      unpublished: [
        {value: :save_changes, label: "Save Changes" }
      ],
      redirected: [
        {value: :re_publish, label: "Republish" }
      ]
    }.freeze

    CURRENT_STATUS = {
      published_being_edited: "Published (being edited)"
    }

    def self.next_states_for(state)
      NEXT_STATE_OPTIONS[state] || []
    end

    def self.current_status(state)
      CURRENT_STATUS[state] || state.to_s.titleize
    end

  end
end
