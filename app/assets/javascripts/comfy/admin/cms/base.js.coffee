window.CMS ||= {}

window.CMS.code_mirror_instances = [ ]

unless Turbolinks?.controller? # Turbolinks 5 verification
  $ -> window.CMS.init()

$(document).on 'page:load turbolinks:load', -> window.CMS.init()

window.CMS.init = ->
  window.CMS.current_path = window.location.pathname
  CMS.set_iframe_layout()
  CMS.slugify()
  CMS.wysiwyg()
  CMS.codemirror()
  CMS.sortable_list()
  CMS.timepicker()
  CMS.page_fragments()
  CMS.page_file_popovers()
  CMS.page_update_preview()
  CMS.categories()
  CMS.files()
  CMS.diff()

window.CMS.slugify = ->
  slugify = (str) ->
    # Trim string and lower case.
    str = str.replace(/^\s+|\s+$/g, '').toLowerCase()

    # Replace special chars.
    replacements = [
      ['à', 'a'],
      ['á', 'a'],
      ['ä', 'ae'],
      ['â', 'a'],
      ['ã', 'a'],
      ['è', 'e'],
      ['é', 'e'],
      ['ë', 'e'],
      ['ê', 'e'],
      ['ì', 'i'],
      ['í', 'i'],
      ['ï', 'i'],
      ['î', 'i'],
      ['ò', 'o'],
      ['ó', 'o'],
      ['ö', 'oe'],
      ['ô', 'o'],
      ['õ', 'o'],
      ['ù', 'u'],
      ['ú', 'u'],
      ['ü', 'ue'],
      ['û', 'u'],
      ['ñ', 'n'],
      ['ç', 'c'],
      ['ß', 'ss'],
      ['·', '-'],
      ['/', '-'],
      [',', '-'],
      [':', '-'],
      [';', '-'],
      ['_', '-'],
      [' ', '-'],
    ]

    for replacement in replacements
      str = str.replace(new RegExp(replacement[0], 'g'), replacement[1])

    # Remove any other URL incompatible characters and replace multiple dashes with just a single one.
    str = str.replace(/[^a-z0-9-]/g, '').replace(/-+/g, '-')

  $('input[data-slugify=true]').bind 'keyup.cms', ->
    $('input[data-slug=true]').val(slugify($(this).val()))


window.CMS.wysiwyg = ->
  csrf_token = $('meta[name=csrf-token]').attr('content')
  csrf_param = $('meta[name=csrf-param]').attr('content')

  if (csrf_param != undefined && csrf_token != undefined)
    params = csrf_param + "=" + encodeURIComponent(csrf_token)

  $('textarea.rich-text-editor, textarea[data-cms-rich-text]').redactor
    minHeight:        160
    autoresize:       true
    imageUpload:      "#{CMS.file_upload_path}?source=redactor&type=image&#{params}"
    imageManagerJson: "#{CMS.file_upload_path}?source=redactor&type=image"
    fileUpload:       "#{CMS.file_upload_path}?source=redactor&type=file&#{params}"
    fileManagerJson:  "#{CMS.file_upload_path}?source=redactor&type=file"
    definedLinks:     "#{CMS.pages_path}?source=redactor"
    buttonSource:     true
    formatting:       ['p', 'h1', 'h2', 'h3', 'h4', 'h5', 'h6']
    plugins:          ['imagemanager', 'filemanager', 'table', 'video', 'definedlinks']
    lang:             CMS.locale
    convertDivs:      false


window.CMS.codemirror = ->
  $('textarea[data-cms-cm-mode]').each (i, element) ->
    cm = CodeMirror.fromTextArea element,
      mode:           $(element).data('cms-cm-mode')
      tabSize:        2
      lineWrapping:   true
      autoCloseTags:  true
      lineNumbers:    true
    CMS.code_mirror_instances.push(cm)
    $(cm.display.wrapper).resizable resize: ->
      cm.setSize($(@).width(), $(@).height())
      cm.refresh()

  $('a[data-toggle="tab"]').on 'shown.bs.tab', ->
    for cm in CMS.code_mirror_instances
      cm.refresh()


window.CMS.sortable_list = ->
  dataIdAttr = 'data-id'
  sortableStore =
    get: (sortable) ->
      Array::map.call sortable.el.children, (el) -> el.getAttribute(dataIdAttr)
    set: (sortable) ->
      $.ajax
        url:      "#{CMS.current_path}/reorder"
        type:     'POST'
        dataType: 'json'
        data:
          order:    sortable.toArray()
          _method:  'PUT'

  for root in document.querySelectorAll('.sortable')
    Sortable.create root,
      handle:     '.dragger'
      draggable:  'li'
      dataIdAttr: dataIdAttr
      store:      sortableStore
      onStart:    (evt) -> evt.from.classList.add('sortable-active')
      onEnd:      (evt) -> evt.from.classList.remove('sortable-active')


window.CMS.timepicker = ->
  $('input[type=text][data-cms-datetime]').flatpickr
    format:     'yyyy-mm-dd hh:ii'
    enableTime: true
    locale:     CMS.locale

  $('input[type=text][data-cms-date]').flatpickr
    format: 'yyyy-mm-dd',
    locale: CMS.locale


window.CMS.page_fragments = ->
  $('select#fragments-toggle').bind 'change.cms', ->
    $.ajax
      url: $(this).data('url'),
      data:
        layout_id: $(this).val()
      complete: ->
        CMS.wysiwyg()
        CMS.timepicker()
        CMS.codemirror()
        CMS.page_file_popovers()


window.CMS.page_file_popovers = ->
  $('[data-toggle="page-file-popover"]').popover
    trigger:    'hover'
    placement:  'top'
    html:       true


window.CMS.page_update_preview = ->
  $('input[name=commit]').click ->
    $(this).parents('form').attr('target', '')
  $('input[name=preview]').click ->
    $(this).parents('form').attr('target', 'comfy-cms-preview')


window.CMS.categories = ->
  $('button.toggle-cat-edit', '.categories-widget').click (event) ->
    event.preventDefault()
    $('.read', '.categories-widget').toggle()
    $('.editable', '.categories-widget').toggle()
    $('.edit', '.categories-widget').toggle()
    $('.done', '.categories-widget').toggle()


window.CMS.diff = ->
  $(".revision").prettyTextDiff
    cleanup:            true
    originalContainer:  '.original'
    changedContainer:   '.current'
    diffContainer:      '.diff .content'

# If we are inside an iframe remove the columns and just keep the center column content.
# This is used for the files widget that opens in a modal window.
window.CMS.set_iframe_layout = ->
  in_iframe = ->
    try
      return window.self != window.top
    catch e
      return true

  $('body').ready ->
    if in_iframe()
      $('body').addClass('in-iframe')
