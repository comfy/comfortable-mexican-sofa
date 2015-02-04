window.CMS ?= {}

window.CMS.files = ->
  window.CMS.filesLibrary = new window.CMS.FilesLibrary

  # Open the files library.
  # Data attributes on the link are settings for the files library such as the
  # mode or the callback when selecting files. For example:
  #   data: { mode: 'select', fieldName: 'fieldname', onSelect: 'selectCmsPageFile' }
  $(document).on 'click', '.cms-files-open', (e) ->
    window.CMS.filesLibrary.open($(this).data(), e)
    e.preventDefault()

  # When clicking a file path in the file list select it to make it easy to copy&paste.
  $(document).on 'click', '.cms-uploader-filelist input[type=text]', ->
    $(this).select()

  # Remove a page file.
  $(document).on 'click', '.cms-page-file-delete', (e) ->
    if confirm $(this).data('ask')
      $("input[name='" + $(this).data('fieldName') + "']").val('')

      $(this).closest('.page-file').fadeOut 'slow', ->
        $(this).parent().find('.cms-files-open').show()
        $(this).remove()

    e.preventDefault()


# This method is called when a page file was selected from the files library.
# file: fileId, fileLabel, fileUrl, file_thumbnail, fileIsImage
# options: a hash with options from the files library open method
window.selectCmsPageFile = (file, options) ->
  field = $('input[name="' + options.fieldName + '"]')
  fileList = $('.page-files[data-page-files-for="' + options.fieldName + '"]')

  field.val(file.fileId)

  entry = fileList.find('.page-file').first().clone()
  entry.attr('id', entry.attr('id') + '_' + file.fileId)
  entry.find('.thumbnail').attr('href', file.fileUrl)
  entry.find('.thumbnail img').attr('src', file.fileThumbnail) if file.fileIsImage
  entry.find('.file-label').text(file.fileLabel)
  entry.find('.cms-files-open').data('currentPageFile', entry.attr('id'))

  # The browse button is either a "replace the current file" or a "add a new file" button...
  if options.currentPageFile
    fileList.find('#' + options.currentPageFile).replaceWith(entry.show())
  else
    fileList.append entry.fadeIn('slow')

  fileList.find('> .cms-files-open').hide()


# When the files library is opened in a modal window we need to remove the
# left and right columns. Triggering this early to prevent flicker.
$('body').ready ->
  in_iframe = ->
    try
      return window.self != window.top
    catch e
      return true

  if in_iframe() && $('body.c-comfy-admin-cms-files').length > 0
    $('body').addClass('in-iframe')
