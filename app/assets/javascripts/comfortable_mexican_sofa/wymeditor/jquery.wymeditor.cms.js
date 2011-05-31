// Options overrides
var cms_wym_options = {
  initSkin:         false,
  boxHtml:          'wymeditor goes here',
  dialogLinkHtml:   'Link Dialog',
  dialogImageHtml:  'Image Dialog',
  dialogTableHtml:  'Table Dialog',
  dialogPasteHtml:  'Paste Dialog'
};

WYMeditor.editor.prototype.dialog = function( dialogType, dialogFeatures, bodyHtml ) {
  // pop-up container
  var dialog = $($('#cms_dialog').get(0) || $('<div id="cms_dialog"></div>'));
  
  var body = '';
  switch(dialogType) {
    case(WYMeditor.DIALOG_LINK):
      body = this._options.dialogLinkHtml;
    break;
    case(WYMeditor.DIALOG_IMAGE):
      body = this._options.dialogImageHtml;
    break;
    case(WYMeditor.DIALOG_TABLE):
      body = this._options.dialogTableHtml;
    break;
    case(WYMeditor.DIALOG_PASTE):
      body = this._options.dialogPasteHtml;
    break;
    case(WYMeditor.PREVIEW):
      body = this._options.dialogPreviewHtml;
    break;
    default:
      body = bodyHtmls;
  }
  
  dialog.html(this.replaceStrings(body));
  dialog.dialog({
    modal:      true,
    width:      800,
    resizable:  false
  });
};