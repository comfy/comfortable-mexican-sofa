//= require jquery
//= require jquery_ujs
//= require jquery-ui
//= require comfortable_mexican_sofa/bootstrap
//= require comfortable_mexican_sofa/codemirror

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
    if($('.categories-widget').length)  $.CMS.enable_categories_widget();
  });

  return {
    
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
      $('input[data-slugify=true]').bind('keyup.cms', function() {
        $('input[data-slug=true]').val(slugify($(this).val()));
      });

      function slugify(str){
        str = str.replace(/^\s+|\s+$/g, '');
        var from = "ÀÁÄÂÃÈÉËÊÌÍÏÎÒÓÖÔÕÙÚÜÛàáäâãèéëêìíïîòóöôõùúüûÑñÇç";
        var to   = "aaaaaeeeeiiiiooooouuuuaaaaaeeeeiiiiooooouuuunncc";
        for (var i = 0, l = from.length; i < l; i++){
          str = str.replace(new RegExp(from[i], "g"), to[i]);
        }
        var chars_to_replace_with_delimiter = new RegExp('[·/,:;_]', 'g');
        str = str.replace(chars_to_replace_with_delimiter, '-');
        var chars_to_remove = new RegExp('[^a-zA-Z0-9 -]', 'g');
        str = str.replace(chars_to_remove, '').replace(/\s+/g, '-').toLowerCase();
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
      // TODO
    },

    enable_codemirror: function(){
      $('textarea.code').each(function(i, element){
        var mode = 'text/html';
        if ($(element).hasClass('css'))  mode = 'css';
        if ($(element).hasClass('js'))   mode = 'javascript';
        CodeMirror.fromTextArea(element, {
          mode:           mode,
          lineWrapping:   true,
          autoCloseTags:  true
        });
      });
    },

    enable_date_picker: function(){
      // $('input[type=text].datetime').datetimepicker({ dateFormat: 'yy-mm-dd' });
      // $('input[type=text].date').datepicker({ dateFormat: 'yy-mm-dd' });
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
      $('a', '.categories-widget .action-links').click(function(){
        $('.categories.read', '.categories-widget').toggle();
        $('.categories.editable', '.categories-widget').toggle();
        $('.edit', '.categories-widget').toggle();
        $('.done', '.categories-widget').toggle();
        return false;
      });
    }
  }
}();
