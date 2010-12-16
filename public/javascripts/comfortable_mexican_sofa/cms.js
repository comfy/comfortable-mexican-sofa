$.CMS = function(){
  var current_path = window.location.pathname;
  var admin_path_prefix = current_path.split('/')[1]
  
  $(document).ready(function(){
    
    $.CMS.slugify();
    $.CMS.tree_methods();
    $.CMS.load_page_blocks();
    $.CMS.enable_rich_text();
    $.CMS.enable_date_picker();
    if($('#page_save').get(0))        $.CMS.enable_page_save_widget();
    if($('#uploader_button').get(0))  $.CMS.enable_uploader();
    
  });
  
  return {
    
    slugify: function(){
      $('input#slugify').bind('keyup.cms', function() {
        $('input#slug').val( slugify( $(this).val() ) );
      });
      
      function slugify(str){
        str = str.replace(/^\s+|\s+$/g, '');
        var from = "ÀÁÄÂÈÉËÊÌÍÏÎÒÓÖÔÙÚÜÛàáäâèéëêìíïîòóöôùúüûÑñÇç·/_,:;";
        var to   = "aaaaeeeeiiiioooouuuuaaaaeeeeiiiioooouuuunncc------";
        for (var i=0, l=from.length ; i<l ; i++) {
          str = str.replace(new RegExp(from[i], "g"), to[i]);
        }
        str = str.replace(/[^a-zA-Z0-9 -]/g, '').replace(/\s+/g, '-').toLowerCase();
        return str;
      }
    },
    
    // Load Page Blocks on layout change
    load_page_blocks: function(){
      $('select#cms_page_cms_layout_id').bind('change.cms', function() {
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
      $('.form_element.cms_tag_page_rich_text textarea, textarea.rich_text').tinymce({
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
       })
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
    
    enable_uploader : function(){
      auth_token = $("meta[name=csrf-token]").attr('content');
      var uploader = new plupload.Uploader({
        container:        'file_uploads',
        browse_button:    'uploader_button',
        runtimes:         'html5',
        unique_names:     true,
        multipart:        true,
        multipart_params: { authenticity_token: auth_token, format: 'js' },
        url:              '/' + admin_path_prefix + '/uploads'
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