//= require comfortable_mexican_sofa/jquery.js
//= require comfortable_mexican_sofa/jquery_ui.js
//= require comfortable_mexican_sofa/jquery_ui_timepicker.js
//= require comfortable_mexican_sofa/rails.js
//= require comfortable_mexican_sofa/codemirror/codemirror.js
//= require comfortable_mexican_sofa/elrte/elrte.js
//= require comfortable_mexican_sofa/elrte/elrte.codemirror.js
//= require comfortable_mexican_sofa/elrte/elrte.sofa_link.js
//= require comfortable_mexican_sofa/elrte/elrte.sofa_image.js

$.CMS = function(){

  var current_path = window.location.pathname;
  var admin_path_prefix = $('meta[name="cms-admin-path"]').attr('content');

  $(function(){
    $.CMS.slugify();
    $.CMS.tree_methods();
    $.CMS.load_page_blocks();
    $.CMS.enable_rich_text();
    $.CMS.enable_codemirror();
    $.CMS.enable_date_picker();
    $.CMS.enable_sortable_list();
    if($('#page_new, #page_edit, #new_page, #edit_page').length) $.CMS.enable_page_form();
    if($('#mirrors').length)            $.CMS.enable_mirrors_widget();
    if($('#page_save').length)          $.CMS.enable_page_save_widget();
    if($('#uploader_button').length)    $.CMS.enable_uploader();
    if($('.categories_widget').length)  $.CMS.enable_categories_widget();
  });

  return {

    // Configuration that can be overriden from the outside. For example:
    //   $.CMS.config.elRTE.toolbar = ['undoredo']
    config: {
      'elRTE': {
        toolbar: ['undoredo', 'sofa_format', 'sofa_style', 'sofa_alignment', 'lists', 'sofa_copypaste', 'sofa_image', 'sofa_links'],
        cssfiles: []
      }
    },

    enable_sortable_list: function(){
      $('.sortable, ul.sortable ul').sortable({
        handle: '.dragger',
        axis:   'y',
        update: function(){
          $.post(current_path + '/reorder', '_method=put&'+$(this).sortable('serialize'));
        }
      })
    },

    slugify: function(){
      $('input#slugify').bind('keyup.cms', function() {
        var slug_input = $('input#slug');
        var delimiter = slug_input.hasClass('delimiter-underscore') ? '_' : '-';
        slug_input.val( slugify( $(this).val(), delimiter ) );
      });

      function slugify(str, delimiter){
        var opposite_delimiter = (delimiter == '-') ? '_' : '-';
        str = str.replace(/^\s+|\s+$/g, '');
        var from = "ÀÁÄÂÃÈÉËÊÌÍÏÎÒÓÖÔÕÙÚÜÛàáäâãèéëêìíïîòóöôõùúüûÑñÇç";
        var to   = "aaaaaeeeeiiiiooooouuuuaaaaaeeeeiiiiooooouuuunncc";
        for (var i=0, l=from.length ; i<l ; i++) {
          str = str.replace(new RegExp(from[i], "g"), to[i]);
        }
        var chars_to_replace_with_delimiter = new RegExp('[·/,:;'+ opposite_delimiter +']', 'g');
        str = str.replace(chars_to_replace_with_delimiter, delimiter);
        var chars_to_remove = new RegExp('[^a-zA-Z0-9 '+ delimiter +']', 'g');
        str = str.replace(chars_to_remove, '').replace(/\s+/g, delimiter).toLowerCase();
        return str;
      }
    },

    // Load Page Blocks on layout change
    load_page_blocks: function(){
      $('select#page_layout_id').bind('change.cms', function() {
        $.ajax({
          url: $(this).data('url'),
          data: ({
            layout_id: $(this).val()
          }),
          complete: function(){
            $.CMS.enable_rich_text();
            $.CMS.enable_date_picker();
          }
        })
      });
    },

    enable_rich_text: function(){
      elRTE.prototype.options.panels.sofa_style     = ['bold', 'italic', 'underline'];
      elRTE.prototype.options.panels.sofa_alignment = ['justifyleft', 'justifycenter', 'justifyright'];
      elRTE.prototype.options.panels.sofa_format    = ['formatblock'];
      elRTE.prototype.options.panels.sofa_copypaste = ['pastetext'];
      elRTE.prototype.options.panels.sofa_links     = ['sofa_link', 'unlink'];

      elRTE.prototype.options.toolbars.sofa = $.CMS.config.elRTE.toolbar;
      elRTE.prototype.options.cssfiles      = $.CMS.config.elRTE.cssfiles;
      
      // BUG: Need to set content to an empty <p> for IE
      if ($.browser.msie){
        $('textarea.rich_text').each(function(){
          if ($(this).val() == ''){
            $(this).val('<p></p>');
          }
        })
      }

      $('textarea.rich_text').elrte({
        height:       300,
        toolbar:      'sofa',
        styleWithCSS: false
      });
    },

    enable_codemirror: function(){
      $('textarea.code').each(function(i, element){
        var mode = 'htmlmixed';
        if ($(element).hasClass('css'))  mode = 'css';
        if ($(element).hasClass('js'))   mode = 'javascript';
        CodeMirror.fromTextArea(element, {
          htmlMode:     true,
          mode:         mode,
          tabMode:      'indent',
          lineWrapping: true
        });
      });
    },

    enable_date_picker: function(){
      $('input[type=text].datetime').datetimepicker({ dateFormat: 'yy-mm-dd' });
      $('input[type=text].date').datepicker({ dateFormat: 'yy-mm-dd' });
    },

    tree_methods: function(){
      $('a.tree_toggle').bind('click.cms', function() {
        $(this).siblings('ul').toggle();
        $(this).toggleClass('closed');
        // object_id are set in the helper (check cms_helper.rb)
        $.ajax({url: [current_path, object_id, 'toggle'].join('/')});
      });

      $('ul.sortable').each(function(){
        $(this).sortable({
          handle: 'div.dragger',
          axis: 'y',
          update: function() {
            $.post(current_path + '/reorder', '_method=put&'+$(this).sortable('serialize'));
          }
        })
      });
    },

    enable_mirrors_widget: function(){
      $('#mirrors select').change(function(){
        window.location = $(this).val();
      })
    },

    enable_page_save_widget : function(){
      $('#page_save input').attr('checked', $('input#page_is_published').is(':checked'));
      $('#page_save button').html($('input#cms_page_submit').val());

      $('#page_save input').bind('click', function(){
        $('input#page_is_published').attr('checked', $(this).is(':checked'));
      })
      $('input#page_is_published').bind('click', function(){
        $('#page_save input').attr('checked', $(this).is(':checked'));
      })
      $('#page_save button').bind('click', function(){
        $('input#cms_page_submit').click();
      })
    },

    enable_page_form : function(){
      $('#tag_namespaces').tabs();
      $('input[name=commit]').click(function() {
        $(this).parents('form').attr('target', '');
      });
      $('input[name=preview]').click(function() {
        $(this).parents('form').attr('target', '_blank');
      });
    },

    enable_uploader : function(){
      var action = $('.file_uploads form').attr('action');
      $('.file_uploads input[type=file]').change(function(){
        var files = $($(this).get(0).files);
        files.each(function(i, file){
          var xhr = new XMLHttpRequest();
          xhr.onreadystatechange = function(e){
            if (xhr.readyState == 4 && xhr.status == 200) {
              eval(xhr.responseText);
            }
          }

          xhr.open('POST', action, true);
          xhr.setRequestHeader('Accept', 'application/javascript');
          xhr.setRequestHeader('X-CSRF-Token', $('meta[name=csrf-token]').attr('content'));
          xhr.setRequestHeader('Content-Type', file.content_type || file.type);
          xhr.setRequestHeader('X-File-Name', file.name);
          xhr.setRequestHeader('X-Requested-With', 'XMLHttpRequest');
          xhr.send(file);
        });
      });
    },

    enable_categories_widget : function(){
      $('.categories_widget a.action_link').click(function(){
        if($(this).data('state') == 'edit'){
          $('.categories.read').hide();
          $('.categories.editable').show();
          $(this).hide();
          $('a.action_link.done').show();
        } else {
          $('.categories.editable').hide();
          $('.categories.read').show();
          $(this).hide();
          $('a.action_link.edit').show();
        }
        return false;
      });
    }
  }
}();
