(function($){
  
  elRTE.prototype.ui.prototype.buttons.sofa_image = function(rte, name) {
    this.constructor.prototype.constructor.call(this, rte, name);
    
    var self    = this;
    self.rte    = rte;
    self.img    = null;
    self.dialog = null;
    
    this.set = function(){
      var src = self.img.data('url');
      self.rte.history.add();
      var img = $(self.rte.doc.createElement('img'));
      img.attr('src', src);
      self.rte.selection.insertNode(img[0]);
      self.rte.ui.update();
      self.dialog.dialog('close');
    }
    
    this.command = function(){
      self.dialog = jQuery(jQuery('#cms_dialog').get(0) || jQuery('<div id="cms_dialog"></div>'));
      self.dialog.dialog({
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
          self.dialog.html(data);
          self.dialog.dialog('open');
          $.CMS.enable_uploader();
          
          $('#cms_dialog .uploaded_files img').click(function(){
            self.img = $(this);
            self.set(this);
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