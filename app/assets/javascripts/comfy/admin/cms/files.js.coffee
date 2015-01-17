(($) ->
  window.CMS or (window.CMS = {})
  window.CMS.files = ->
    modal = $('.cms-files-modal')
    $('.cms-files-open-modal').on 'click', (e) ->
      modal.on 'show.bs.modal', ->
        iframe    = modal.find('iframe')
        iframeSrc = modal.data('iframe-src')
        if iframe.attr('src') != iframeSrc
          iframe.attr('src', iframeSrc)

      modal.modal(show: true)
      e.preventDefault()

    # Make the files library modal window fill the browsers available height.
    modal.on 'show.bs.modal', (e) ->
      height = $(window).height() - 60
      $(e.target).find('.modal-content').css('height', "#{height}px")

    $(window).on 'resize', ->
      height = $(window).height() - 60
      modal.find('.modal-content').css('height', "#{height}px")

    # When clicking a file path in the file list select it to make
    # it easy to copy&paste.
    $(document).on 'click', '.cms-uploader-filelist input[type=text]', ->
      $(this).select()

) jQuery