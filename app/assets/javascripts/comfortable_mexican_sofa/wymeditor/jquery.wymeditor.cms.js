// Options overrides
var cms_wym_options = {
  
  initSkin:         false,
  lang:             'en',
  
  updateSelector:    'form',
  updateEvent:       'submit',
  
  containersItems: [
    { 'name': 'H1',                   'title': 'Heading_1',       'css': 'wym_containers_h1' },
    { 'name': 'H2',                   'title': 'Heading_2',       'css': 'wym_containers_h2' },
    { 'name': 'H3',                   'title': 'Heading_3',       'css': 'wym_containers_h3' },
    { 'name': 'P',                    'title': 'Paragraph',       'css': 'wym_containers_p' },
    { 'name': 'PRE',                  'title': 'Preformatted',    'css': 'wym_containers_pre' }
  ],
  
  toolsItems: [
    { 'name': 'Bold',                 'title': 'Strong',          'css': 'wym_tools_strong' }, 
    { 'name': 'Italic',               'title': 'Emphasis',        'css': 'wym_tools_emphasis' },
    { 'name': 'InsertOrderedList',    'title': 'Ordered_List',    'css': 'wym_tools_ordered_list' },
    { 'name': 'InsertUnorderedList',  'title': 'Unordered_List',  'css': 'wym_tools_unordered_list' },
    { 'name': 'InsertTable',          'title': 'Table',           'css': 'wym_tools_table' },
    { 'name': 'CreateLink',           'title': 'Link',            'css': 'wym_tools_link' },
    { 'name': 'Unlink',               'title': 'Unlink',          'css': 'wym_tools_unlink' },
    { 'name': 'InsertImage',          'title': 'Image',           'css': 'wym_tools_image' },
    { 'name': 'Paste',                'title': 'Paste_From_Word', 'css': 'wym_tools_paste' },
    { 'name': 'ToggleHtml',           'title': 'HTML',            'css': 'wym_tools_html' }
  ],
  
  classesItems: [
    { 'name': 'AlignLeft',    'title': 'Align_Left',    'css': 'align_left' },
    { 'name': 'AlignCenter',  'title': 'Align_Center',  'css': 'align_center' },
    { 'name': 'AlignRight',   'title': 'Align_Left',    'css': 'align_right' }
  ],
  
  boxHtml:            '<div class="wym_box">'
                    +   '<div class="wym_toolbar">'
                    +     WYMeditor.CONTAINERS
                    +     WYMeditor.CLASSES
                    +     WYMeditor.TOOLS
                    +   '</div>'
                    +   '<div class="wym_area_main">'
                    +     WYMeditor.HTML
                    +     WYMeditor.IFRAME
                    +   '</div>'
                    + '</div>',
                    
  containersHtml:     '<ul class="wym_containers wym_toolbar_section">'
                    +   WYMeditor.CONTAINERS_ITEMS
                    + '</ul>',
                    
  toolsHtml:          '<ul class="wym_tools wym_toolbar_section">'
                    +   WYMeditor.TOOLS_ITEMS
                    + '</ul>',
                    
  classesHtml:        '<ul class="wym_classes wym_toolbar_section">'
                    +   WYMeditor.CLASSES_ITEMS
                    + '</ul>',
                    
  htmlHtml:           '<div class="wym_html">'
                    +   '<textarea class="wym_html_val code"></textarea>'
                    + '</div>',
                    
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