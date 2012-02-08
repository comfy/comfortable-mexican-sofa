(function($) {
  elRTE.prototype.codeMirror = true;
  elRTE.prototype.updateSourceOld = elRTE.prototype.updateSource;
  elRTE.prototype.updateSource = function() {
    if( this.codeMirror ) {
      var blockHtmlElements = 'h[1-6]|div|p|blockquote|pre|form|label|select|input|button|ol|ul|dd|dt|li|table|thead|tbody|td|th|tr';
      
      var html = this.filter.source($(this.doc.body).html());
      html = html.replace(new RegExp('(</?(' + blockHtmlElements + ')[^<]*?>)\\s*', 'gi'), '$1\n')
        .replace(new RegExp('\\s*(</?(' + blockHtmlElements + ')[^<]*?>)', 'gi'), '\n$1');
      this.source.val(html);
        
      this.codeMirror = CodeMirror.fromTextArea(this.source[0], {
        mode:         'htmlmixed',
        tabMode:      'indent',
        lineWrapping: true
      });
      for (var i = 0, e = this.codeMirror.lineCount(); i < e; ++i) this.codeMirror.indentLine(i);
      
      this.source.css('display','block')
        .css('position','absolute')
        .css('z-index','-1');
    } else {
      this.updateSourceOld();
    }
  }

  elRTE.prototype.updateEditorOld = elRTE.prototype.updateEditor;
  elRTE.prototype.updateEditor = function() {
    if( this.codeMirror ){
      this.codeMirror.toTextArea();
      this.source.css('display','none');	
    }
    this.updateEditorOld();
  }
})(jQuery);