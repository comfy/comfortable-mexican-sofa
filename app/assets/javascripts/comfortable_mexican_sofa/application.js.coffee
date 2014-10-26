#= require jquery
#= require bootstrap-sprockets
#= require jquery_ujs
#= require jquery-ui
#= require tinymce-jquery
#= require codemirror
#= require codemirror/modes/css
#= require codemirror/modes/htmlmixed
#= require codemirror/modes/javascript
#= require codemirror/modes/markdown
#= require codemirror/modes/xml
#= require codemirror/addons/edit/closetag
#= require bootstrap
#= require comfortable_mexican_sofa/lib/bootstrap-datetimepicker
#= require comfortable_mexican_sofa/lib/diff
#= require comfortable_mexican_sofa/cms/uploader
#= require comfortable_mexican_sofa/cms/files

$ ->
  CMS.init()

window.CMS ||= {}

window.CMS.current_path = window.location.pathname
window.CMS.code_mirror_instances = []

window.CMS.init = ->
  CMS.slugify()
  CMS.wysiwyg()
  CMS.codemirror()
  CMS.sortable_list()
  CMS.timepicker()
  CMS.page_blocks()
  CMS.mirrors()
  CMS.page_update_preview()
  CMS.page_update_publish()
  CMS.categories()
  CMS.files()

window.CMS.slugify = ->
  slugify = (str) ->
    str   = str.replace(/^\s+|\s+$/g, '')
    from  = "ÀÁÄÂÃÈÉËÊÌÍÏÎÒÓÖÔÕÙÚÜÛàáäâãèéëêìíïîòóöôõùúüûÑñÇç"
    to    = "aaaaaeeeeiiiiooooouuuuaaaaaeeeeiiiiooooouuuunncc"
    for i in [0..from.length - 1]
      str = str.replace(new RegExp(from[i], "g"), to[i])
    chars_to_replace_with_delimiter = new RegExp('[·/,:;_]', 'g')
    str = str.replace(chars_to_replace_with_delimiter, '-')
    chars_to_remove = new RegExp('[^a-zA-Z0-9 -]', 'g')
    str = str.replace(chars_to_remove, '').replace(/\s+/g, '-').toLowerCase()

  $('input[data-slugify=true]').bind 'keyup.cms', ->
    $('input[data-slug=true]').val(slugify($(this).val()))


window.CMS.wysiwyg = ->
  tinymce.init
    selector:         'textarea[data-cms-rich-text]'
    plugins:          ['link', 'image', 'code']
    toolbar:          'undo redo | styleselect | bullist numlist | link unlink image | code'
    menubar:          false
    statusbar:        false
    relative_urls:    false
    entity_encoding : 'raw'

window.CMS.codemirror = ->
  $('textarea[data-cms-cm-mode]').each (i, element) ->
    cm = CodeMirror.fromTextArea element,
      mode:           $(element).data('cms-cm-mode')
      lineWrapping:   true
      autoCloseTags:  true
      lineNumbers:    true
    CMS.code_mirror_instances.push(cm)
    $(cm.display.wrapper).resizable resize: ->
      cm.setSize($(@).width(), $(@).height())
      cm.refresh()

  $('a[data-toggle="tab"]').on 'shown', ->
    for cm in CMS.code_mirror_instances
      cm.refresh()
    return
  return


window.CMS.sortable_list = ->
  $('.sortable').sortable
    handle: 'div.dragger'
    axis:   'y'
    update: ->
      $.post("#{CMS.current_path}/reorder", "_method=put&#{$(this).sortable('serialize')}")


window.CMS.timepicker = ->
  $('input[type=text][data-cms-datetime]').datetimepicker
    format:     'yyyy-mm-dd hh:ii'
    minView:    0
    autoclose:  true
  $('input[type=text][data-cms-date]').datetimepicker
    format:     'yyyy-mm-dd'
    minView:    2
    autoclose:  true


window.CMS.page_blocks = ->
  $('select#page_layout_id').bind 'change.cms', ->
    $.ajax
      url: $(this).data('url'),
      data:
        layout_id: $(this).val()
      beforeSend: ->
        tinymce.remove()
      complete: ->
        CMS.wysiwyg()
        CMS.timepicker()
        CMS.codemirror()
        CMS.reinitialize_page_blocks() if CMS.reinitialize_page_blocks?

window.CMS.mirrors = ->
  $('#mirrors select').change ->
    window.location = $(this).val()


window.CMS.page_update_preview = ->
  $('input[name=commit]').click ->
    $(this).parents('form').attr('target', '')
  $('input[name=preview]').click ->
    $(this).parents('form').attr('target', '_blank')


window.CMS.page_update_publish = ->
  widget = $('#form-save')
  $('input', widget).prop('checked', $('input#page_is_published').is(':checked'))
  $('button', widget).html($('input[name=commit]').val())

  $('input', widget).click ->
    $('input#page_is_published').prop('checked', $(this).is(':checked'))
  $('input#page_is_published').click ->
    $('input', widget).prop('checked', $(this).is(':checked'))
  $('button', widget).click ->
    $('input[name=commit]').click()


window.CMS.categories = ->
  $('a', '.categories-widget .action-links').click (event) ->
    event.preventDefault()
    $('.categories.read', '.categories-widget').toggle()
    $('.categories.editable', '.categories-widget').toggle()
    $('.edit', '.categories-widget').toggle()
    $('.done', '.categories-widget').toggle()
