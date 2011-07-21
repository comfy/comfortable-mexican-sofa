//= require comfortable_mexican_sofa/jquery.js
//= require comfortable_mexican_sofa/jquery_ui.js
//= require comfortable_mexican_sofa/rails.js
//= require comfortable_mexican_sofa/codemirror/codemirror.js

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
    if($('form#page_edit, form#page_new').get(0)) $.CMS.enable_page_save_form();
    if($('#mirrors').get(0))          $.CMS.enable_mirrors_widget();
    if($('#page_save').get(0))        $.CMS.enable_page_save_widget();
    if($('#uploader_button').get(0))  $.CMS.enable_uploader();
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
      $('input#slugify').bind('keyup.cms', function() {
        var slug_input = $('input#slug');
        var delimiter = slug_input.hasClass('delimiter-underscore') ? '_' : '-';
        slug_input.val( slugify( $(this).val(), delimiter ) );
      });

      function slugify(str, delimiter){
        var opposite_delimiter = (delimiter == '-') ? '_' : '-';
        str = str.replace(/^\s+|\s+$/g, '');
        var from = "ÀÁÄÂÈÉËÊÌÍÏÎÒÓÖÔÙÚÜÛàáäâèéëêìíïîòóöôùúüûÑñÇç";
        var to   = "aaaaeeeeiiiioooouuuuaaaaeeeeiiiioooouuuunncc";
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
      $('select#cms_page_layout_id').bind('change.cms', function() {
        $.ajax({
          url: ['/' + admin_path_prefix, 'pages', $(this).attr('data-page-id'), 'form_blocks'].join('/'),
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
      $('textarea.rich_text').wymeditor(cms_wym_options);
    },
    
    enable_codemirror: function(){
      $('textarea.code').each(function(i, element){
        var mode = 'htmlmixed';
        if ($(element).hasClass('css'))  mode = 'css';
        if ($(element).hasClass('js'))   mode = 'javascript';
        CodeMirror.fromTextArea(element, {
          htmlMode: true,
          mode:     mode,
          tabMode: 'indent'
        });
      });
    },

    enable_date_picker: function(){
      $('input[type=datetime]').datepicker();
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

    enable_page_save_form : function(){
      $('input[name=commit]').click(function() {
        $(this).parents('form').attr('target', '');
      });
      $('input[name=preview]').click(function() {
        $(this).parents('form').attr('target', '_blank');
      });
    },

    enable_uploader : function(){
      auth_token = $("meta[name=csrf-token]").attr('content');
      var uploader = new plupload.Uploader({
        container:        'file_uploads',
        browse_button:    'uploader_button',
        runtimes:         'html5',
        unique_names:     true,
        multipart:        true,
        multipart_params: { authenticity_token: auth_token, format: 'js' },
        url:              $('#file_uploads').data('path')
      });
      uploader.init();
      uploader.bind('FilesAdded', function(up, files) {
        $.each(files, function(i, file){
          $('#uploaded_files').prepend(
            '<div class="file pending" id="' + file.id + '">' + file.name + '</div>'
          );
        });
        uploader.start();
      });
      uploader.bind('Error', function(up, err) {
        alert('File Upload failed')
      });
      uploader.bind('FileUploaded', function(up, file, response){
        $('#' + file.id).replaceWith(response.response);
      });
    }
  }
}();