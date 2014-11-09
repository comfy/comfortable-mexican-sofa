# CMS Uploader using plupload http://www.plupload.com/. Code inspired by
# plupload queue widget https://github.com/moxiecode/plupload/tree/master/js/jquery.plupload.queue
#
#= require moxie
#= require plupload.dev
#= require plupload/i18n/de
#= require plupload.settings
(($, o) ->
  window.CMS or (window.CMS = {})
  window.CMS.uploader = (target, settings) ->

    # Add a file to the file list.
    addFile = (file) ->
      fileList = $(".cms-uploader-filelist", target)

      fileList.prepend("
        <tr id='#{file.id}' class='temp'>
          <td><div class='icon'></div></td>
          <td class='main' colspan=2>
            <div class='progress'>
              <div class='progress-bar progress-bar-striped active'>
                <span>#{file.name}</span>
              </div>
            </div>
          </td>
          <td>
            <a class='btn btn-sm btn-danger pull-right cms-uploader-file-delete' href='#'>Delete</a>
          </td>
        </tr>
      ")

      $("#" + file.id + " a.cms-uploader-file-delete").click (e) ->
        uploader.removeFile(file)
        e.preventDefault()

      updateFileStatus(file)

    # Remove a file from the file list.
    removeFile = (file) ->
      $("#" + file.id).remove()

    # Update a files upload status in the file list.
    updateFileStatus = (file) ->
      progress_bar = $("##{file.id} .progress-bar", target)
      if file.status == plupload.UPLOADING
        progress_bar.css('width', "#{file.percent}%")
      if file.status == plupload.FAILED
        progress_bar.css('width', '100%').addClass('progress-bar-danger')
        $('span', progress_bar).html(file.error_message)

    uploader = undefined
    id      = target.attr("id")

    unless id
      id = plupload.guid()
      target.attr('id', id)

    settings = $.extend(
      runtimes:       "html5,browserplus,silverlight,flash,gears"
      dragdrop:       true
      drop_element:   "#{id}-drag-drop-target"
      browse_button:  "#{id}-browse"
      container:      id
      file_data_name: "file[file]"
      headers:
        Accept: "text/plupload"
    , settings)

    uploader = new plupload.Uploader(settings)
    uploader.bind "PostInit", (up) ->

      # Show drag and drop info and attach events if drag and drop is
      # supported and enabled.
      if up.settings.dragdrop and up.features.dragdrop
        drop_element = $(up.settings.drop_element)

        # When dragging over the document add a class to the drop target
        # that puts it ontop of every element and remove that class when
        # dropping or leaving the drop target. Otherwise the dragleave
        # event would fire whenever we dragging over a child element inside
        # the drop target such as text nodes or stuff.
        $(document).bind 'dragenter', (e) ->
          drop_element.addClass('cms-uploader-drag-drop-target-active')

        drop_element.bind 'drop dragleave', (e) ->
          drop_element.removeClass('cms-uploader-drag-drop-target-active')

      else
        $('.cms-uploader-drag-drop-info', target).hide()

    # Need to bind this before initialization to handle initialization errors too.
    uploader.bind 'Error', (up, err) ->
      file    = err.file
      message = undefined

      if file
        # Get error message from the server response. Not all runtimes
        # support this though.
        message = err.response

        # If no error message is in the server response get standard
        # plupload error messages. This will have descriptive error message
        # for something like file size or file format errors but for
        # server errors it will only display a general error message.
        unless message
          message = err.message
          if err.details
            message += " (#{err.details})"
        file.status = plupload.FAILED
        file.error_message = message
        updateFileStatus file

      if err.code == plupload.INIT_ERROR
        alert _('Error: Initialisation error. Reload to try again.')

    uploader.init()
    uploader.bind 'FilesAdded', (up, files) ->
      $.each files, (i, file) ->
        addFile file

      # Auto start upload when files are added.
      uploader.start()

    uploader.bind 'UploadProgress', (up, file) ->
      updateFileStatus(file)

    uploader.bind "FileUploaded", (up, file, info) ->
      # Replace the dummy file entry in the file list with the the entry
      # from the server response.
      $("tr##{file.id}").replaceWith(info.response)

    uploader.bind 'FilesRemoved', (up, files) ->
      $.each files, (i, file) ->
        removeFile file

    # Call setup function
    if settings.setup
      settings.setup(uploader)

) jQuery, mOxie