# TODO: edit spans with specific attributes

editable_box_selector = '.inline-editable'
target_url = '/cms-admin/sites/54/pages/115/update_blocks'

htmlEditor = {}


flagAsChanged = () ->
  console.info("Element's contents changed. #{Math.random()}")
  $(this).data('submitflag', '1')

#
# Handles response from data submission to back-end. Since page has changed,
# a refresh should be triggered.
#
blockUpdateHandler = (data, textStatus, jqXHR) ->
  console.log(data)
  console.log(textStatus)
  if textStatus == 'success'
    window.location.href = window.location.href # Reload.
  else
    alert("Error in update: #{data.error}")

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
    jQuery.post(target_url, submitData, blockUpdateHandler)
  else
    console.info('No elements flagged for submission.')

  false # Stop event's propagation

instantiateSaveButton = () ->
  saveButton = $('<input id="submitChanges" type="submit" value="Save2">')
  saveButton.on('click', submitChangedBlocks)

  saveButtonWrapper = $('<div id="editorWrapper"></div>')
  saveButtonWrapper.append('<form><textarea id="wysihtml5-textarea" placeholder="Enter your text ..." autofocus></textarea>
    </form>')
  saveButtonWrapper.append(saveButton)

  $('body').append(saveButtonWrapper)
  htmlEditor = new wysihtml5.Editor("wysihtml5-textarea", { parserRules:  wysihtml5ParserRules })

populateEditor = ($el) ->
  htmlEditor.clear()
  htmlEditor.composer.commands.exec("insertHTML", $el.data('raw-content'));

$ ->
  console?.log('inside cms_edit_content')

  for el in $(editable_box_selector)
    $el = $(el)
    $el.attr('contenteditable', true)
    $el.css('border', '5px dashed black')
    $el.css('display', 'block')
    # Because elements are not necessarily inputs, checking for focus events:
    $el.on('change', flagAsChanged)
    # $el.on('click', showEditor)
    # console.log($el)

  # http://stackoverflow.com/questions/1391278/contenteditable-change-events
  $('body')
    .on 'focus', '[contenteditable]', ->
        $this = $(this)
        $this.data 'before', $this.data('raw-content')
        populateEditor($this)
        return $this
    .on 'blur keyup paste input', '[contenteditable]', ->
        $this = $(this)
        if $this.data('before') isnt $this.data('raw-content')
            $this.data 'before', $this.data('raw-content')
            $this.trigger('change')
        return $this

  instantiateSaveButton()

  return
