#= require comfy/admin/cms/lib/diff/diff_match_patch.min
#= require comfy/admin/cms/lib/diff/pretty_text_diff.min

$(document).on 'page:load ready', ->
  $("table.diff").prettyTextDiff ->
    cleanup: true
    originalContainer:  'tr td.original'
    changedContainer:   'tr td.changed'
    diffContainer:      'tr td.diff'
