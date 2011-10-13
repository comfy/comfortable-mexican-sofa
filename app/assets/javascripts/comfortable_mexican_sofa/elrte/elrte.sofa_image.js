(function($){
  
  elRTE.prototype.ui.prototype.buttons.sofa_image = function(rte, name) {
    this.constructor.prototype.constructor.call(this, rte, name);
    
    this.command = function(){
      
      var cms_dialog = jQuery(jQuery('#cms_dialog').get(0) || jQuery('<div id="cms_dialog"></div>'));
      cms_dialog.dialog({
        modal         : true,
        resizable     : false,
        closeOnEscape : true,
        autoOpen      : false
      });
      
      jQuery.ajax({
        url: '/' + $('meta[name="cms-admin-path"]').attr('content') + 
          '/sites/' +
          $('meta[name="cms-site-id"]').attr('content') +
          '/dialogs/images'
      })
      
    }
    
    this.update = function(){
      this.domElem.removeClass('disabled');
    }
  }
  elRTE.prototype.options.buttons.sofa_image = 'Image';
  elRTE.prototype.options.panels.sofa_image = ['sofa_image'];
  
})(jQuery);