$(".file.<%= dom_id(@file) %>").fadeOut 'slow', ->
  $(this).remove()