# TODO: edit spans with specific attributes

#
# Selectors
#
editable_box_selector   = '.inline-editable'
editor_wrapper_selector = '#editorWrapper'
editor_submit_status = '#editorSubmitStatus'
editor_submit_status_wrapper = editor_submit_status+'Wrapper'

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


# hides the message box
hideMessage = (callback) ->
  $(editor_submit_status_wrapper).fadeOut 1250, ->
    callback()

# shows and sets a message and a class in the message box
showMessage = (message, class_name) ->
  # removeClass with no params removes all classes
  $(editor_submit_status_wrapper).show().find(editor_submit_status).removeClass().addClass(class_name).html(message)

#
# Handles response from data submission to back-end. Since page has changed,
# a refresh should be triggered.
#
blockUpdateSuccess = (data, textStatus, jqXHR) ->
  
  $("span[data-block-id='#{data.block_id}']").replaceWith(data.content)
  showMessage("Success!", "success")
  hideMessage(() ->
    $(editor_wrapper_selector).hide()
  );
  initializeEdiatableAreas("span[data-block-id='#{data.block_id}']")

blockUpdateError = (xhr) ->
  error = $.parseJSON(xhr.responseText).error

  showMessage(error, "error")


submitChangedBlock = () ->
  # console.log('Submitting blocks')
  showMessage('Saving...')
  blockToSubmit = {
    page_id: editorMetadata.page_id,
    id: editorMetadata.block_id,
    content: htmlEditor.getValue()
  }
  # console.log(blockToSubmit)

  page_id = editorMetadata.page_id

  target_url = "/cms-admin/pages/#{page_id}/update_block"

  submitData = { block: blockToSubmit }
  # console.log("Ready for POST submission to page #{page_id}: #{JSON.stringify(submitData)}")

  $.ajax({
    type: "POST",
    url: target_url,
    data: submitData,
    success: blockUpdateSuccess
    error: blockUpdateError
  });
  
  false # Stop event's propagation

instantiateForm = () ->
  saveButton = $('<input id="submitChanges" type="submit" value="Save">')
  saveButton.on('click', submitChangedBlock)

  saveButtonWrapper = $('<div id="editorWrapper"></div>')
  saveButtonWrapper.append('<div id="editorSubmitStatusWrapper" style="display:none"><span id="editorSubmitStatus"></span></div>')

  saveButtonWrapper.append('
    <form>
      <a href="#" id="closeEditor">&times;</a>
      <span id="editorTitle">Edit your content.</span>'+
      toolbar+
      '<textarea id="wysihtml5-textarea" placeholder="Enter your text ..." autofocus></textarea>
    </form>
  ').hide()

  saveButtonWrapper.append(saveButton)
  console.log(saveButtonWrapper.html())
  $('body').append(saveButtonWrapper)
  htmlEditor = new wysihtml5.Editor("wysihtml5-textarea", { parserRules:  wysihtml5ParserRules, toolbar: "wysihtml5-toolbar" })

addCloseEvent = () ->
  $('#closeEditor')
    .on 'click', ->
      closeEditor()

  $(document).on 'keyup', (e) ->
    if e.keyCode == 27
      closeEditor()
  

closeEditor = () ->
  editorMetadata.block_id = ''
  $(editor_wrapper_selector).hide()

#
# http://stackoverflow.com/questions/1391278/contenteditable-change-events
#
initializeEdiatableAreas = (selector=editable_box_selector) ->
  $('body')
    .on 'click', selector, ->
        $this = $(this)
        $this.data 'before', $this.data('raw-content')
        populateEditor($this)
        return $this
    .on 'blur keyup paste input', selector, ->
        $this = $(this)
        if $this.data('before') isnt $this.data('raw-content')
          $this.data 'before', $this.data('raw-content')
          $this.trigger('change')
        return $this

populateEditor = ($el) ->
  editorMetadata.page_id  = $el.data('pageId')
  editorMetadata.block_id = $el.data('blockId')

  htmlEditor.clear()
  htmlEditor.composer.commands.exec("insertHTML", $el.data('raw-content').replace('[[', '{{').replace(']]', '}}'))
  $(editor_wrapper_selector).show()

$ ->
  # console?.log('inside cms_edit_content')

  initializeEdiatableAreas()
  instantiateForm()
  addCloseEvent()

  return
