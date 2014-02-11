#= require comfortable_mexican_sofa/lib/diff/diff_match_patch.min
#= require comfortable_mexican_sofa/lib/diff/pretty_text_diff.min

$ ->
  $("table.diff").prettyTextDiff ->
    cleanup: true
    originalContainer:  'tr td.original'
    changedContainer:   'tr td.changed'
    diffContainer:      'tr td.diff'