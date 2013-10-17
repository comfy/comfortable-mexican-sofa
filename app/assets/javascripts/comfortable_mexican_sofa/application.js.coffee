#= require jquery
#= require jquery_ujs
#= require jquery.ui.all
#= require comfortable_mexican_sofa/lib/bootstrap
#= require comfortable_mexican_sofa/lib/codemirror
#= require comfortable_mexican_sofa/lib/wysihtml5
#= require comfortable_mexican_sofa/lib/bootstrap-wysihtml5
#= require comfortable_mexican_sofa/lib/bootstrap-datetimepicker

$ ->
  CMS.init()

window.CMS =
  current_path:           window.location.pathname
  code_mirror_instances:  []
  
  init: ->
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
    CMS.uploader()


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
  $('textarea[data-rich-text]').each (i, element) ->
    $(element).wysihtml5
      html:         true
      color:        false
      stylesheets:  []

  $(document).on('shown', '.bootstrap-wysihtml5-insert-image-modal', ( ->
    modal_body = $(this).find('.modal-body')
    $('.uploaded-files').clone().appendTo(modal_body)
  ))

  $(document).on('hide', '.bootstrap-wysihtml5-insert-image-modal', ( ->
    $(this).find('.modal-body .uploaded-files').remove()
  ))

  $(document).on('click', '.bootstrap-wysihtml5-insert-image-modal .file.image', ( ->
    url = $(this).find('.file-info').data('url')
    $('.bootstrap-wysihtml5-insert-image-modal.in input.bootstrap-wysihtml5-insert-image-url').val(url)
    $('.bootstrap-wysihtml5-insert-image-modal.in .modal-footer .btn-primary').click()
  ))

window.CMS.codemirror = ->
  $('textarea[data-cm-mode]').each (i, element) ->
    cm = CodeMirror.fromTextArea element,
      mode:           $(element).data('cm-mode')
      lineWrapping:   true
      autoCloseTags:  true
      lineNumbers:    true
    CMS.code_mirror_instances.push(cm)
  
  $('a[data-toggle="tab"]').on 'shown', ->
    for cm in CMS.code_mirror_instances
      cm.refresh()

window.CMS.sortable_list = ->
  $('.sortable').sortable
    handle: 'div.dragger'
    axis:   'y'
    update: ->
      $.post("#{CMS.current_path}/reorder", "_method=put&#{$(this).sortable('serialize')}")


window.CMS.timepicker = ->
  $('input[type=text][data-datetime]').datetimepicker
    format:     'yyyy-mm-dd hh:ii'
    minView:    'day'
    autoclose:  true
  $('input[type=text][data-date]').datetimepicker
    format:     'yyyy-mm-dd'
    minView:    'minute'
    autoclose:  true


window.CMS.page_blocks = ->
  $('select#page_layout_id').bind 'change.cms', ->
    $.ajax
      url: $(this).data('url'),
      data: 
        layout_id: $(this).val()
      complete: ->
        CMS.wysiwyg()
        CMS.timepicker()


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


window.CMS.uploader = ->
  form    = $('.file-uploader form')
  iframe  = $('iframe#file-upload-frame')
  
  $('input[type=file]', form).change -> form.submit()
    
  iframe.load -> upload_loaded()
  
  upload_loaded = ->
    i = iframe[0]
    d = if i.contentDocument
      i.contentDocument
    else if i.contentWindow
      i.contentWindow.document
    else
      i.document
    
    if d.body.innerHTML
      raw_string  = d.body.innerHTML
      json_string = raw_string.match(/\{(.|\n)*\}/)[0]
      json = $.parseJSON(json_string)
      files = $($('<div/>').html(json.view).text()).hide()
      $('.uploaded-files').prepend(files)
      files.map ->
        $(this).fadeIn()

wysihtml5.regexp['url'] = /[a-zA-z0-9\/-_&=?!#$;~.\[\]]+/gi;