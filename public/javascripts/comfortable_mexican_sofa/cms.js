$.CMS = function(){
  
  $(function(){
    $.CMS.slugify();
    $.CMS.tree_methods();
    $.CMS.load_page_blocks();
    $.CMS.enable_rich_text();
    $.CMS.enable_codemirror();
    $.CMS.enable_date_picker();
    $.CMS.enable_desc_toggle();
    $.CMS.enable_sortable_list();
    if($('form.new_cms_page, form.edit_cms_page').get(0)) $.CMS.enable_page_save_form();
    if($('#page_save').get(0))        $.CMS.enable_page_save_widget();
    if($('#uploader_button').get(0))  $.CMS.enable_uploader();
  });
  
  return {
    current_path: null,
    
    admin_path_prefix: null,
    
    enable_sortable_list: function(){
      $('ul.sortable, ul.sortable ul').sortable({
        handle: 'div.dragger',
        axis: 'y',
        update: function(){
          $.post($.CMS.current_path + '/reorder', '_method=put&'+$(this).sortable('serialize'));
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
          url: ['/' + $.CMS.admin_path_prefix, 'pages', $(this).attr('data-page-id'), 'form_blocks'].join('/'),
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
      $('textarea.rich_text').tinymce({
         theme : "advanced",
         plugins: "",
         theme_advanced_buttons1 : "formatselect,|,bold,italic,underline,strikethrough,|,justifyleft,justifycenter,justifyright,justifyfull,|,bullist,numlist,|,link,unlink,anchor,image,|,code",
         theme_advanced_buttons2 : "",
         theme_advanced_buttons3 : "",
         theme_advanced_buttons4 : "",
         theme_advanced_toolbar_location : "top",
         theme_advanced_toolbar_align : "left",
         theme_advanced_statusbar_location : "bottom",
         theme_advanced_resizing : true,
         theme_advanced_resize_horizontal : false
       });
    },
    
    enable_codemirror: function(){
      $('textarea.code').each(function(i, element){
        CodeMirror.fromTextArea(element, {
          basefiles: [
            "/javascripts/comfortable_mexican_sofa/codemirror/codemirror_base.js",
            "/javascripts/comfortable_mexican_sofa/codemirror/parse_xml.js",
            "/javascripts/comfortable_mexican_sofa/codemirror/parse_css.js",
            "/javascripts/comfortable_mexican_sofa/codemirror/parse_js.js",
            "/javascripts/comfortable_mexican_sofa/codemirror/parse_html_mixed.js"
          ],
          stylesheet: "/javascripts/comfortable_mexican_sofa/codemirror/codemirror.css"
        });
      });
      
      $('textarea.code_css').each(function(i, element){
        CodeMirror.fromTextArea(element, {
          basefiles: [
            "/javascripts/comfortable_mexican_sofa/codemirror/codemirror_base.js",
            "/javascripts/comfortable_mexican_sofa/codemirror/parse_css.js"
          ],
          stylesheet: "/javascripts/comfortable_mexican_sofa/codemirror/codemirror.css"
        });
      });
      
      $('textarea.code_js').each(function(i, element){
        CodeMirror.fromTextArea(element, {
          basefiles: [
            "/javascripts/comfortable_mexican_sofa/codemirror/codemirror_base.js",
            "/javascripts/comfortable_mexican_sofa/codemirror/parse_js.js"
          ],
          stylesheet: "/javascripts/comfortable_mexican_sofa/codemirror/codemirror.css"
        });
      });
    },
    
    enable_date_picker: function(){
      $('input[type=datetime]').datepicker();
    },
    
    enable_desc_toggle: function(){
      $('.form_element .desc .desc_toggle').click(function(){
        $(this).toggle();
        $(this).siblings('.desc_content').toggle();
      })
    },
    
    tree_methods: function(){
      $('a.tree_toggle').bind('click.cms', function() {
        $(this).siblings('ul').toggle();
        $(this).toggleClass('closed');
        // object_id are set in the helper (check cms_helper.rb)
        $.ajax({url: [$.CMS.current_path, object_id, 'toggle'].join('/')});
      });
      
      $('ul.sortable').each(function(){
        $(this).sortable({
          handle: 'div.dragger',
          axis: 'y',
          update: function() {
            $.post($.CMS.current_path + '/reorder', '_method=put&'+$(this).sortable('serialize'));
          }
        })
      });
    },
    
    enable_page_save_widget : function(){
      $('#page_save input').attr('checked', $('input#cms_page_is_published').is(':checked'));
      $('#page_save button').html($('input#cms_page_submit').val());
      
      $('#page_save input').bind('click', function(){
        $('input#cms_page_is_published').attr('checked', $(this).is(':checked'));
      })
      $('input#cms_page_is_published').bind('click', function(){
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
        url:              '/' + $.CMS.admin_path_prefix + '/uploads'
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