$.CMS.RTEditor = function(){
  
  $(document).ready(function() { 
    $.CMS.RTEditor.init();
  }).ajaxSend(function(){
    $.CMS.RTEditor.reset();
  }).ajaxSuccess(function(){
    $.CMS.RTEditor.init();
  });
  
  return {
    init: function(){
      if($('textarea.richText').length > 0){
        $.CMS.RTEditor.toolbars();
        $('textarea.richText').each(function(i){
          CKEDITOR.replace(this.id, {
            resize_maxWidth: 668,
            resize_minWidth: 668,
            toolbar: 'CmsFull',
            toolbar_CmsFull: $.CMS.RTEditor.full_toolbars,
            on: { instanceReady : function( ev ) {
                    this.dataProcessor.writer.indentationChars = '  ';
                    this.dataProcessor.writer.setRules( '#', { breakBeforeClose: true });
                  }
              }
          });
        });
      }
    },
    
    toolbars: function() {
      $.CMS.RTEditor.basic_toolbars = [
        [ 'Copy','Cut','Paste','PasteText','PasteFromWord', '-', 'Bold','Italic','Underline','Strike','-', 'NumberedList','BulletedList', '-', 'JustifyLeft', 'JustifyCenter', 'JustifyRight', 'JustifyBlock', '-', 'Undo','Redo', '-', 'Link','Unlink','Anchor', '-', 'Table' ]
      ];
      
      $.CMS.RTEditor.full_toolbars = $.CMS.RTEditor.basic_toolbars.concat([ '/',
        ['Subscript','Superscript', '-', 'Source']
      ]);
    },
    
    reset: function(){
      $.each(CKEDITOR.instances, function(i, v){
        v.destroy();
      });
    }
  };
}();
