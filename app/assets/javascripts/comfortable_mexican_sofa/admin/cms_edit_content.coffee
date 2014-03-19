# TODO: edit spans with specific attributes

#
# Selectors
#
editable_box_selector   = '.inline-editable'
editor_wrapper_id = 'editorWrapper'
editor_wrapper_selector = "##{editor_wrapper_id}"
editor_submit_status = '#editorSubmitStatus'
editor_submit_status_wrapper = "#{editor_submit_status}Wrapper"
inline_editor_selector = '#inlineEditor'
close_editor_selector = '#closeEditor'

# if you need to access the editor for some reason
htmlEditor = false

# hides the message box after 1.25 seconds
hideMessage = (callback) ->
  $(editor_submit_status_wrapper).fadeOut 1250, ->
    callback()

# shows and sets a message and a class in the message box
showMessage = (message, class_name) ->
  # removeClass with no params removes all classes
  $(editor_submit_status_wrapper).show().find(editor_submit_status).removeClass().addClass(class_name).html(message)

# fires on success of the form submission
blockUpdateSuccess = (e, data) ->
  $("span[data-block-id='#{data.block_id}']").replaceWith(data.content)
  showMessage("Success!", "success")
  hideMessage(() ->
    $(editor_wrapper_selector).hide()
  );

# fires on error of the form submisssion
blockUpdateError = (e, xhr) ->
  error = $.parseJSON(xhr.responseText).error
  showMessage(error, "error")

# adds an placeholder element for the form to be dropped into
addFormPlaceHolder = () ->
  editorWrapper = $("<div id=\"#{editor_wrapper_id}\"></div>")
  $('body').append(editorWrapper)

addEditorCloseEvents = () ->
  $('body')
    .on 'click', close_editor_selector, ->
      closeEditor()

  $(document).on 'keyup', (e) ->
    if e.keyCode == 27
      closeEditor()

closeEditor = () ->
  $(editor_wrapper_selector).hide()

# retrievs the form from the endpoint in the admin.
getForm = (element, callback) ->
  editableArea = $(element)
  block_id = editableArea.data('block-id')
  page_id = editableArea.data('page-id')
  url = "/cms-admin/pages/#{page_id}/edit_block/#{block_id}"
  return $.get(url, callback)

# sets up the click for the editable areas.
initializeEdiatableAreas = () ->
  $('body')
    .on 'click', editable_box_selector, ->
        getForm this, (data) ->
          editor_wrapper = $(editor_wrapper_selector).html(unescape(data))
          htmlEditor = new wysihtml5.Editor("wysihtml5-textarea", { 
            parserRules:  wysihtml5ParserRules,
            toolbar: "wysihtml5-toolbar" 
          })
          $(editor_wrapper_selector).show()

listenForSubmission = () ->
  $(document)
    .on 'ajax:beforeSend', inline_editor_selector, () ->
      showMessage('Loading...', '')
    .on 'ajax:success', inline_editor_selector, blockUpdateSuccess
    .on 'ajax:error', inline_editor_selector, blockUpdateError

$ ->
  addFormPlaceHolder()
  initializeEdiatableAreas()
  listenForSubmission()
  addEditorCloseEvents()

  return
