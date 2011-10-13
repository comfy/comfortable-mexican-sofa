(function($){
  elRTE.prototype.ui.prototype.buttons.sofa_link = function(rte, name){
    this.constructor.prototype.constructor.call(this, rte, name);
    
    var self = this;
    
    this.command = function(){
      dialog_opts = {
        rtl   : this.rte.rtl, 
        submit: function(e, d) { e.stopPropagation(); e.preventDefault(); self.set(); d.close(); },
        close : function() {self.rte.browser.msie && self.rte.selection.restoreIERange(); },
        dialog: {
          width : 'auto',
          width : 430,
          title : this.rte.i18n('Link')
        }
      }
      d = new elDialogForm();
      d.append('BALHHH');
      d.open();
      
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