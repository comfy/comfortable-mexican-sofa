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
target_url_postfix = '/update_block'

htmlEditor = {}
editorMetadata = {}
toolbar = '
<div id="wysihtml5-toolbar" style="display: none;">
  <a data-wysihtml5-command="bold">bold</a>
  <a data-wysihtml5-command="italic">italic</a>
  
  <!-- Some wysihtml5 commands require extra parameters -->
  <!-- commenting this out for now. But maybe in the future dynamically create these based on the color scheme in our \'wizard\' -->
  <!--
  <a data-wysihtml5-command="foreColor" data-wysihtml5-command-value="red">red</a>
  <a data-wysihtml5-command="foreColor" data-wysihtml5-command-value="green">green</a>
  <a data-wysihtml5-command="foreColor" data-wysihtml5-command-value="blue">blue</a>
  -->
  
  <!-- Some wysihtml5 commands like \'createLink\' require extra paramaters specified by the user (eg. href) -->
  <a data-wysihtml5-command="createLink">insert link</a>
  <div data-wysihtml5-dialog="createLink" style="display: none;">
    <label>
      Link:
      <input data-wysihtml5-dialog-field="href" value="http://" class="text">
    </label>
    <a data-wysihtml5-dialog-action="save">OK</a> <a data-wysihtml5-dialog-action="cancel">Cancel</a>
  </div>
</div>'

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

instantiateForm = () ->
  saveButton = $('<input id="submitChanges" type="submit" value="Save2">')
  saveButton.on('click', submitChangedBlock)

  saveButtonWrapper = $('<div id="editorWrapper"></div>')

  saveButtonWrapper.append('
    <form>
      <a href="#" id="closeEditor">&times;</a>
      <span id="editorTitle">Edit your content.</span>'+
      toolbar+
      '<textarea id="wysihtml5-textarea" placeholder="Enter your text ..." autofocus></textarea>
    </form>
  ')

  saveButtonWrapper.append(saveButton)
  

  $('body').append(saveButtonWrapper)
  htmlEditor = new wysihtml5.Editor("wysihtml5-textarea", { parserRules:  wysihtml5ParserRules, toolbar: "wysihtml5-toolbar" })

addCloseEvent = () ->
  $('#closeEditor')
    .on 'click', ->
      alert('you just closed me')

#
# http://stackoverflow.com/questions/1391278/contenteditable-change-events
#
initializeEdiatableAreas = () ->
  $('body')
    .on 'click', editable_box_selector, ->
        $this = $(this)
        $this.data 'before', $this.data('raw-content')
        populateEditor($this)
        return $this
    .on 'blur keyup paste input', editable_box_selector, ->
        $this = $(this)
        if $this.data('before') isnt $this.data('raw-content')
          $this.data 'before', $this.data('raw-content')
          $this.trigger('change')
        return $this

populateEditor = ($el) ->
  editorMetadata.page_id  = $el.data('pageId')
  editorMetadata.block_id = $el.data('blockId')

  htmlEditor.clear()
  htmlEditor.composer.commands.exec("insertHTML", $el.data('raw-content'))

$ ->
  console?.log('inside cms_edit_content')

  for el in $(editable_box_selector)
    $el = $(el)
    $el.css('border', '1px dashed black')
    $el.css('display', 'block')

  initializeEdiatableAreas()
  instantiateForm()
  addCloseEvent()

  return
