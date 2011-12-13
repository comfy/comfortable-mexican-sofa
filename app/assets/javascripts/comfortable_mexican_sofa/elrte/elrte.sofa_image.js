(function($){
  
  elRTE.prototype.ui.prototype.buttons.sofa_image = function(rte, name) {
    this.constructor.prototype.constructor.call(this, rte, name);
    
    this.command = function(){
      
      var cms_dialog = jQuery(jQuery('#cms_dialog').get(0) || jQuery('<div id="cms_dialog"></div>'));
      cms_dialog.dialog({
        title         : rte.i18n('Image'),
        modal         : true,
        resizable     : false,
        width         : 800,
        closeOnEscape : true,
        autoOpen      : false
      });
      
      jQuery.ajax({
        url: '/' + $('meta[name="cms-admin-path"]').attr('content') + '/sites/' + $('meta[name="cms-site-id"]').attr('content') + '/dialog/image',
        success: function(data){
          cms_dialog.html(data);
          cms_dialog.dialog('open');
          $.CMS.enable_uploader();
          var opts = {
            rte   : rte,
            dialog: cms_dialog
          }
          $('#cms_dialog .uploaded_files img').click(opts, function(){
            var src = $(this).attr('src');
            opts.rte.history.add();
            var img = $(opts.rte.doc.createElement('img'));
            img.attr('src', src);
            opts.rte.selection.insertNode(img[0]);
            opts.rte.ui.update();
            opts.dialog.dialog('close');
          });
        }
      })
    }
    
    this.update = function(){
      this.domElem.removeClass('disabled');
    }
  }
  elRTE.prototype.options.buttons.sofa_image = 'Image';
  elRTE.prototype.options.panels.sofa_image = ['sofa_image'];
  
})(jQuery);