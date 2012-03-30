(function($) {
  elRTE.prototype.ui.prototype.buttons.sofa_link = function(rte, name) {
    var self;
    self = this;
    this.constructor.prototype.constructor.call(this, rte, name);
    this.href = $('<input type="text" size="42" placeholder="http://"/>');
    this.target = $('<select />').append($('<option />').val('_blank').text(this.rte.i18n('In new window (_blank)'))).append($('<option />').val('').text(this.rte.i18n('In this window')));
    this.link = null;

    this.set = function() {
      self.rte.history.add();

      if (this.href.val().length === 0) {
        this.rte.dom.unwrap(this.link[0]);
      } else {
        this.link.attr("href", this.href.val());
        this.link.attr("target", this.target.val());
        if (this.is_new) {
          if (this.img) {
            if (this.img) {
              this.rte.dom.wrap(this.img, this.link[0]);
            }
          } else {
            this.rte.dom.wrap(this.rte.selection.getEnd(), this.link[0]);
          }
        }
      }
      return self.rte.ui.update();
    };

    this.command = function() {
      var dialog, opts;
      this.is_new = false;
      this.img = this.rte.selection.getNode();
      if (this.img.nodeName !== 'IMG') {
        this.img = null;
      }
      this.link = this.node();
      if (!this.link) {
        this.link = $('<a />');
        this.is_new = true;
      }
      
      opts = {
        submit: function(event, dialog) {
          event.stopPropagation();
          event.preventDefault();
          dialog.close();
          return self.set();
        },
        dialog: {
          title: this.rte.i18n("Link"),
          width: 450,
          resizable: true,
          modal: true
        }
      };
      
      dialog = new elDialogForm(opts);
      this.href.val(this.link.attr('href'));
      dialog.append([this.rte.i18n("URL"), this.href], null, true);
      dialog.append([this.rte.i18n("Target"), this.target], null, true);
      return dialog.open();
    };

    this.update = function() {
      var n;
      n = this.rte.selection.getNode();
      if (this.rte.dom.selfOrParentLink(n)) {
        return this.domElem.removeClass("disabled").addClass("active");
      } else if (!this.rte.selection.collapsed() || n.nodeName === "IMG") {
        return this.domElem.removeClass("disabled active");
      } else {
        return this.domElem.addClass("disabled").removeClass("active");
      }
    };

    this.node = function() {
      var i, n, selection, selections;
      n = this.rte.selection.getEnd();
      n = this.rte.dom.selfOrParentLink(n);
      if (!n) {
        selections = ($.browser.msie ? this.rte.selection.selected() : this.rte.selection.selected({
          wrap: false
        }));
        for (i in selections) {
          selection = selections[i];
          if (this.isLink(selection)) {
            n = selection;
            break;
          }
        }
        if (!n) {
          n = this.rte.dom.parent(selections[0], this.isLink) || this.rte.dom.parent(selections[selections.length - 1], this.isLink);
        }
      }
      
      return n ? $(n) : null;
    };

    this.isLink = function(node) {
      return node.nodeName === "A" && node.href;
    };
    return self;
  };

  elRTE.prototype.options.buttons.sofa_link = 'Link';

})(jQuery);