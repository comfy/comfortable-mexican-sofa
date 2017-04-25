#= require comfy/admin/cms/lib/diff/diff_match_patch.min
#= require comfy/admin/cms/lib/diff/pretty_text_diff.min

unless Turbolinks?.controller? # Turbolinks 5 verification
  $ -> initDiff()
$(document).on 'page:load turbolinks:load', -> initDiff()

initDiff = ->
  $("table.diff").prettyTextDiff ->
    cleanup: true
    originalContainer:  'tr td.original'
    changedContainer:   'tr td.changed'
    diffContainer:      'tr td.diff'
