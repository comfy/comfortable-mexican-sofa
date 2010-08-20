$.CMS.CodeMirror = function(){
  
  $(document).ready(function(){
    $.CMS.CodeMirror.init();
  }).ajaxSuccess(function(){
    $.CMS.CodeMirror.init();
  });
  
  return {
    init: function(){
      $('.codeTextArea').each(function(i, el){
          CodeMirror.fromTextArea(el, {
            parserfile: ["parsexml.js", "parsecss.js", "tokenizejavascript.js", "parsejavascript.js", "parsehtmlmixed.js"],
            stylesheet: ["/stylesheets/codemirror/xmlcolors.css", "/stylesheets/codemirror/jscolors.css", "/stylesheets/codemirror/csscolors.css"],
            path: "/javascripts/codemirror/",
            iframeClass: 'codeMirrorIframe'
          });
        });
      }
    }
}();
