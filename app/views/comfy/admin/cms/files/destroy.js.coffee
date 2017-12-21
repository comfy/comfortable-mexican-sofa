$("li[data-id=<%= @file.id %>]").fadeOut 'slow', ->
  $(this).remove()
