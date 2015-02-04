window.CMS ?= {}

class window.CMS.FilesLibrary
  constructor: ->
    @modal = $('.cms-files-modal')
    @mode = 'browse' # The other mode is 'select' which will show a select button next to each file.
    @type = 'all' # Type of files to display. The other type is 'image'.
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
    @type = options.type || 'all'
    @onSelect = options.onSelect
    @modal.modal('show')

  close: ->
    @modal.modal('hide')

  selectFile: (file) ->
    if $.isFunction(@onSelect)
      @onSelect(file, @options)
    else if $.isFunction(window[@onSelect])
      window[@onSelect](file, @options)

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

    if iframe.attr('src') != @_iframeSource()
      iframe.attr('src', @_iframeSource())

    @_fitSize()

  _iframeSource: ->
    src = @modal.data('iframe-src')
    src = @_paramReplace(src, 'type', 'image') if @type == 'image'
    src

  # Add or replace a parameter value in a HREF
  _paramReplace: (href, name, value) ->
    re = new RegExp('[\\?&]' + name + '=([^&#]*)')
    matches = re.exec(href)
    newString = undefined
    if matches == null
      # if there are no params, append the parameter
      newString = href + '?' + name + '=' + value
    else
      delimeter = matches[0].charAt(0)
      newString = href.replace(re, delimeter + name + '=' + value)
    newString


  _fitSize: ->
    height = $(window).height() - 60
    @modal.find('.modal-content').css('height', "#{height}px")
