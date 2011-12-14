(function($){
  elRTE.prototype.ui.prototype.buttons.sofa_link = function(rte, name){
    this.constructor.prototype.constructor.call(this, rte, name);
    
    var self      = this;
    self.link_url = null;
    
    // attaching event handler to the image insertion form
    $(document).on('submit', '#cms_dialog form.link_url', function(){
      self.link_url = $(this).find('input[name=link_url]').val();
      self.set();
      return false;
    });
    
    this.set = function(){
      self.rte.history.add();
      self.rte.doc.execCommand('createLink', false, self.link_url);
      self.rte.ui.update();
      self.dialog.dialog('close');
    }
    
    this.command = function(){
      self.dialog = jQuery(jQuery('#cms_dialog').get(0) || jQuery('<div id="cms_dialog"></div>'));
      self.dialog.dialog({
        title         : rte.i18n('Link'),
        modal         : true,
        resizable     : false,
        width         : 800,
        closeOnEscape : true,
        autoOpen      : false
      });
      
      jQuery.ajax({
        url: '/' + $('meta[name="cms-admin-path"]').attr('content') + '/sites/' + $('meta[name="cms-site-id"]').attr('content') + '/dialog/link',
        success: function(data){
          self.dialog.html(data);
          self.dialog.dialog('open');
        }
      })
    }
    
    this.update = function(){
      var n = this.rte.selection.getNode();
      if (this.rte.dom.selfOrParentLink(n)) {
        this.domElem.removeClass('disabled').addClass('active');
      } else if (this.rte.dom.selectionHas(function(n) { return n.nodeName == 'A' && n.href; })) {
        this.domElem.removeClass('disabled').addClass('active');
      } else if (!this.rte.selection.collapsed() || n.nodeName == 'IMG') {
        this.domElem.removeClass('disabled active');
      } else {
        this.domElem.addClass('disabled').removeClass('active');
      }
    }
  }
  
  elRTE.prototype.options.buttons.sofa_link = 'Link';
  
})(jQuery)