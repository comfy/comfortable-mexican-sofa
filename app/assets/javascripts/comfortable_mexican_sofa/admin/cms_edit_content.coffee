# TODO: edit spans with specific attributes

#
# http://stelfox.net/blog/2013/12/access-get-parameters-with-coffeescript/
#
getParams = ->
  query = window.location.search.substring(1)
  #
  # Override query from current script.
  # http://stackoverflow.com/questions/4099456/how-to-check-for-script-src-match-then-reassign-src
  #
  scripts = document.getElementsByTagName("script")
  for script in scripts
    if(script.src.indexOf("cms_edit_content") != -1)
      query = script.src[(script.src.indexOf('?') + 1)...script.src.length]
      break;

  raw_vars = query.split("&")

  params = {}

  for v in raw_vars
    [key, val] = v.split("=")
    params[key] = decodeURIComponent(val)

  params

editable_box_selector = '.inline-editable'
params = getParams()
target_url_prefix  = "/cms-admin/sites/#{params.site_id}/pages/"
# console.log("target_url_prefix: #{target_url_prefix}")
target_url_postfix = '/update_blocks'

htmlEditor = {}
editorMetadata = {}

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

submitChangedBlock = () ->
  console.log('Submitting blocks')
  blockToSubmit = {
    page_id: editorMetadata.page_id,
    id: editorMetadata.block_id,
    content: htmlEditor.getValue()
  }
  console.log(blockToSubmit)

  page_id = editorMetadata.page_id

  target_url = target_url_prefix + page_id + target_url_postfix
  console.info("Will post to: #{target_url}")

  submitData = { block: blockToSubmit }
  console.log("Ready for POST submission to page #{page_id}: #{JSON.stringify(submitData)}")
  jQuery.post(target_url, submitData, blockUpdateHandler)


  false # Stop event's propagation

instantiateSaveButton = () ->
  saveButton = $('<input id="submitChanges" type="submit" value="Save2">')
  saveButton.on('click', submitChangedBlock)

  saveButtonWrapper = $('<div id="editorWrapper"></div>')
  saveButtonWrapper.append('<form>
    <textarea id="wysihtml5-textarea" placeholder="Enter your text ..." autofocus></textarea>
    </form>')
  saveButtonWrapper.append(saveButton)

  $('body').append(saveButtonWrapper)
  htmlEditor = new wysihtml5.Editor("wysihtml5-textarea", { parserRules:  wysihtml5ParserRules })

populateEditor = ($el) ->
  editorMetadata.page_id  = $el.data('pageId')
  editorMetadata.block_id = $el.data('blockId')

  htmlEditor.clear()
  htmlEditor.composer.commands.exec("insertHTML", $el.data('raw-content'));

$ ->
  console?.log('inside cms_edit_content')

  for el in $(editable_box_selector)
    $el = $(el)
    $el.attr('contenteditable', true)
    $el.css('border', '5px dashed black')
    $el.css('display', 'block')

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
