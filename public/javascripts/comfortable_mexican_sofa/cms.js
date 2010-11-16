$.CMS = function(){
  var current_path = window.location.pathname;
  
  $(document).ready(function(){
    // Slugify
    $('input#slugify').bind('keyup.cms', function() {
      $('input#slug').val( $.CMS.slugify( $(this).val() ) );
    });

    // Expand/Collapse tree function
    $('a.tree_toggle').bind('click.cms', function() {
      $(this).siblings('ul').toggle();
      $(this).toggleClass('closed');
      // object_id are set in the helper (check cms_helper.rb)
      $.ajax({url: [current_path, object_id, 'toggle'].join('/')});
    });

    // Show/hide details
    $('a.details_toggle').bind('click.cms', function() {
      $(this).parent().siblings('table.details').toggle();
    });

    // Sortable trees
    $('ul.sortable').each(function(){
      $(this).sortable({  handle: 'div.dragger',
        update: function() {
          $.post(current_path + '/reorder', '_method=put&'+$(this).sortable('serialize'));
        }
      })
    });
    
    // Load Page Blocks on layout change
    $('select#cms_page_cms_layout_id').bind('change.cms', function() {
      $.ajax({url: [$(this).attr('data-path-prefix'), 'pages', $(this).attr('data-page-id'), 'form_blocks'].join('/'), data: ({ layout_id: $(this).val()})})
    })

  }); // End $(document).ready()



  return {
    slugify: function(str){
      str = str.replace(/^\s+|\s+$/g, '');
      var from = "ÀÁÄÂÈÉËÊÌÍÏÎÒÓÖÔÙÚÜÛàáäâèéëêìíïîòóöôùúüûÑñÇç·/_,:;";
      var to   = "aaaaeeeeiiiioooouuuuaaaaeeeeiiiioooouuuunncc------";
      for (var i=0, l=from.length ; i<l ; i++) {
        str = str.replace(new RegExp(from[i], "g"), to[i]);
      }
      str = str.replace(/[^a-zA-Z0-9 -]/g, '').replace(/\s+/g, '-').toLowerCase();
      return str;
    }
  }
}();
