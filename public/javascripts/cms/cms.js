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

    // Show/Hide Advanced
    $('a#more_options').bind('click.cms', function() {
      $(this).text(($(this).text() == 'Show more') ? 'Show less' : 'Show more');
      $('.advanced').toggle();
    })

    // Load Page Blocks on layout change
    $('select#cms_page_cms_layout_id').bind('change.cms', function() {
      $.ajax({url: ['/cms-admin/pages', page_id, 'form_blocks'].join('/'), data: ({ layout_id: $(this).val()})})
    })

    // Datepicker
    $('input[data-datepicker]').datepicker({dateFormat : 'yy-mm-dd'});

    // Add Category Subform
    $.CMS.category_subform_submit();
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
    },
    toggle_category_selections: function(obj) {
      if (obj.checked == true){
        $(obj).parents("ul#root_categories li")
          .children("div.form_element")
          .find("input[type=checkbox]")
          .each(function() {
            this.checked = true;
          });
      } else {
        // NOT WORKING
        $(obj).parent().parent().parent().find("input[type=checkbox]").each(function() {
          this.checked = false;
        });
      }
    },
    category_subform_submit: function(){
      $('#new_category input[type=button]').bind('click.cms', function() {
        var currently_selected = [];
        $.post(
          '/cms-admin/categories.js',
          $("#new_category [name^=cms_category]")
            .add("input[name=item_type]")
            .add("input[name='authenticity_token']")
            .serialize(),
          function(data) {
            $("#cms_category_label").val("").focus();
            $.CMS.category_subform_submit();
          }
        );
        return false;
      })

      $('#new_category input[name^=cms_category]').bind('keypress.cms', function(event) {
        if (event.keyCode == '13') {
          event.preventDefault();
          $('#new_category input[type=button]').trigger('click.cms');
        }
      })
    }
  }
}();
