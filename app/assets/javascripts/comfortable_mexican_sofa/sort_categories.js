/*
* This Sort Strategy is done with just two database updates
* The first one to update all the records bellow the current category
* The second one to update all the records upon the current category
*/

(function($) {
  $('.sortable_unitary').sortable({
    handle: '.dragger',
    axis:   'y',
    previous_position: null,

    start: function(event, ui) {
      // the start position before the drag operation
      this.previous_position = ui.item.siblings().andSelf().index(ui.item);
    },

    update: function(event, ui){
      var self = this;
      //acts_as_list top position is 1
      var position = ui.item.siblings().andSelf().index(ui.item) + 1;
      ui.item.find('.dragger').addClass('processing');
      var item_id = parseInt(ui.item.attr('id').split('_').pop());
      $('.sortable_unitary').sortable("disable");
      var current_path = window.location.pathname;
      $.post(current_path + '/reorder', '_method=put&id=' + item_id + '&position=' + position)
        .error(function() {
          var siblings = ui.item.siblings();
          var last_element;
          var offset;
          var is_last = false;

          if (siblings.length > self.previous_position){
            last_element = siblings.eq(self.previous_position);
            offset = last_element.offset().top;
          }else{
            //last element must have special treatment
            last_element = siblings.last();
            is_last = true;
            //we need to maintain offset position, but since it will be decreased, we increase it now
            offset = last_element.offset().top + last_element.height();
          }
          //if moving from bottom to top, we need to remove one position
          if(self.previous_position > position){
            offset = offset - last_element.height();
          }

          //set absolute position to allow moving over elements
          ui.item.css('width', ui.item.innerWidth());
          ui.item.css('height', ui.item.innerHeight());
          ui.item.css('position','absolute');
          ui.item.css('top', ui.item.offset().top);
          //move it
          ui.item.find('.item').effect("highlight", { color: '#ff9999'}, 1500);
          ui.item.animate({top: offset}, {duration:500, complete: function(){
            //remove absolute positioning
            ui.item.css('position','');
            ui.item.css('height', '');
            //insert it at old place
            if (is_last){
              ui.item.insertAfter(last_element);
            }else{
              ui.item.insertBefore(last_element);
            }
            alert($('#errormessage').text());
          }});
        })
        .complete(function(){
          $('.sortable_unitary').sortable("enable");
          ui.item.find('.dragger').removeClass('processing');
          self.previous_position = null;
        });
    }
  })
})(jQuery);