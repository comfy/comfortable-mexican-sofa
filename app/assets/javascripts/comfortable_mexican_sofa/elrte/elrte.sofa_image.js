(function($){
  
  elRTE.prototype.ui.prototype.buttons.sofa_image = function(rte, name) {
    this.constructor.prototype.constructor.call(this, rte, name);
    
    var self      = this;
    self.img_src  = null;
    self.dialog   = null;
    
    // attaching event handler to the image insertion form
    $(document).on('submit', '#cms_dialog form.image_url', function(){
      self.img_src = $(this).find('input[name=image_url]').val();
      self.set();
      return false;
    });
    
    // attaching event handlers to images
    $(document).on('click', '#cms_dialog .uploaded_files .file_info', function(){
      console.log($(this))
      console.log($(this).parents('#cms_dialog'))
      ui_control = $(this).parents('#cms_dialog').data('ui_control')
      if (ui_control) {
        ui_control.img_src = $(this).data('url');
        ui_control.set();
        $(this).parents('#cms_dialog').data('ui_control', null)
      }
      return false;
    });
    
    this.set = function(){
      self.rte.history.add();
      var img = $(self.rte.doc.createElement('img'));
      img.attr('src', self.img_src);
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
          console.log($(self.dialog))
          $(self.dialog).data('ui_control', self)
          $.CMS.enable_uploader();
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