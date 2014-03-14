# TODO: edit spans with spedific attributes

$ ->
  console?.log('inside cms_edit_content')
  editable_box_selector = '.inner_box'
  for el in $(editable_box_selector)
  	$el = $(el)
  	$el.attr("contenteditable", true)
  	$el.css("border", "1px dashed black")
  	console.log($el)
