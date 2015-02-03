window.CMS ?= {}

class window.CMS.FilesLibrary
  constructor: ->
    @modal = $('.cms-files-modal')
    @mode = 'browse' # The other mode is 'select' which will show a select button next to each file.
    @onSelect = undefined # A string with a method name that is called when the library is in select mode and a file was selected
    @options = undefined # Library options given via the open method. This is also passed to the +onSelect+ callback method.

    @modal.on 'show.bs.modal', =>
      @_onOpen()

    $(window).on 'resize', =>
      @_fitSize()

    # The select-file button in the file list. This button is inside the modal
    # windows iframe so we need to call our +selectFile+ method on the parent window.
    $(document).on 'click', '.cms-files-select-file', (e) ->
      window.parent.CMS.filesLibrary.selectFile($(this).data())
      e.preventDefault()

  open: (options, event) ->
    @options = options
    @mode = options.mode || 'browse'
    @onSelect = options.onSelect
    @modal.modal('show')

  close: ->
    @modal.modal('hide')

  selectFile: (file) ->
    window[@onSelect](file, @options) if @onSelect
    @close()

  _onOpen: ->
    iframe = @modal.find('iframe')

    # When the iframe has finished loading or is shown, check if we are in
    # file-select mode and hide the select-file button if not.
    iframe.load =>
      elm = iframe.contents().find('.cms-files-select-file')
      if @mode == 'select' then elm.show() else elm.hide()

    try
      elm = iframe.contents().find('.cms-files-select-file')
      if @mode == 'select' then elm.show() else elm.hide()

    iframeSrc = @modal.data('iframe-src')
    if iframe.attr('src') != iframeSrc
      iframe.attr('src', iframeSrc)

    @_fitSize()

  _fitSize: ->
    height = $(window).height() - 60
    @modal.find('.modal-content').css('height', "#{height}px")
