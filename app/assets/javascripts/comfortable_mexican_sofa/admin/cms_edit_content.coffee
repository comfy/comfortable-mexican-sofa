# TODO: edit spans with spedific attributes

editable_box_selector = '.inline-editable'
target_url = '/cms-admin/sites/54/pages/115/update_block'

flagAsChanged = () ->
  console.info("Element's contents changed. #{Math.random()}")
  $(this).data('submitflag', '1')

submitChangedBlocks = () ->
  console.log('Submitting blocks')
  blocksToSubmit = []
  page_id = ''

  for el in $(editable_box_selector)
    $el = $(el)

    if $el.data('submitflag')? && $el.data('submitflag') == '1'
      console.info('submitting element:')
      # Assume same page id:
      page_id = $el.data('pageId')
      blocksToSubmit.push({
        page_id: $el.data('pageId'),
        id: $el.data('blockId'),
        content: $el.html()
      })

  console.log(blocksToSubmit)
  if blocksToSubmit.length > 0
    submitData = { blocks: blocksToSubmit }
    console.log("Ready for POST submission to page #{page_id}: #{JSON.stringify(submitData)}")
    jQuery.post(target_url, submitData, (data, textStatus, jqXHR) ->
      console.log(data)
      console.log(textStatus)
    )
  else
    console.info('No elements flagged for submission.')

  false # Stop event's propagation

instantiateSaveButton = () ->
  saveButton = $('<a href="#" id="submitChanges" style="margin-bottom: 10px;">Save</a>')
  saveButton.on('click', submitChangedBlocks)

  saveButtonWrapper = $('<div></div>')
  saveButtonWrapper.append(saveButton)

  $('body').append(saveButtonWrapper)

$ ->
  console?.log('inside cms_edit_content')

  for el in $(editable_box_selector)
  	$el = $(el)
  	$el.attr('contenteditable', true)
  	$el.css('border', '5px dashed black')
  	$el.css('display', 'block')
  	# Because elements are not necessaringly inputs, checking for focus events:
  	$el.on('focus', flagAsChanged)
  	console.log($el)

  instantiateSaveButton()
  return
