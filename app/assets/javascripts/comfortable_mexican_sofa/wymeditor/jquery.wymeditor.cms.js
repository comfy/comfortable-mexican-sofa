// -- Options overrides -----------------------------------------------------
var cms_wym_options = {
  
  initSkin:         false,
  lang:             $('meta[name="cms-locale"]').attr('content'),
  
  basePath:   $('meta[name="cms-js-assets-base-path"]').attr('content') + '/wymeditor/',
  wymPath:    'disabled',
  jQueryPath: 'disabled',
  
  updateSelector:    'form',
  updateEvent:       'submit',
  
  containersItems: [
    { 'name': 'H1',   'title': 'Heading_1',     'css': 'wym_containers_h1' },
    { 'name': 'H2',   'title': 'Heading_2',     'css': 'wym_containers_h2' },
    { 'name': 'H3',   'title': 'Heading_3',     'css': 'wym_containers_h3' },
    { 'name': 'P',    'title': 'Paragraph',     'css': 'wym_containers_p' },
    { 'name': 'PRE',  'title': 'Preformatted',  'css': 'wym_containers_pre' }
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
    { 'name': 'align_left',    'title': 'Align_Left',    'expr': '*' },
    { 'name': 'align_center',  'title': 'Align_Center',  'expr': '*' },
    { 'name': 'align_right',   'title': 'Align_Left',    'expr': '*' }
  ],
  
  dialog:           jQuery(jQuery('#cms_dialog').get(0) || jQuery('<div id="cms_dialog"></div>')),
  
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
                    +   '<textarea class="wym_html_val"></textarea>'
                    + '</div>',
                    
  dialogLinkHtml:     '<form id="wym_dialog_form">'
                    +   '<div class="form_element">'
                    +     '<div class="label">'
                    +       '<label>{URL}</label>'
                    +     '</div>'
                    +     '<div class="value">'
                    +       '<input type="text" name="href"/>'
                    +     '</div>'
                    +   '</div>'
                    +   '<div class="form_element">'
                    +     '<div class="label">'
                    +       '<label>{Title}</label>'
                    +     '</div>'
                    +     '<div class="value">'
                    +       '<input type="text" name="title"/>'
                    +     '</div>'
                    +   '</div>'
                    +   '<div class="form_element submit_element">'
                    +     '<div class="value">'
                    +       '<input name="commit" type="submit" value="{Submit}" />'
                    +     '</div>'
                    +   '</div>'
                    + '</form>',
  
  dialogImageHtml:    '<form id="wym_dialog_form">'
                    +   '<div class="form_element">'
                    +     '<div class="label">'
                    +       '<label>{URL}</label>'
                    +     '</div>'
                    +     '<div class="value">'
                    +       '<input type="text" name="src"/>'
                    +     '</div>'
                    +   '</div>'
                    +   '<div class="form_element">'
                    +     '<div class="label">'
                    +       '<label>{Alternative_Text}</label>'
                    +     '</div>'
                    +     '<div class="value">'
                    +       '<input type="text" name="alt"/>'
                    +     '</div>'
                    +   '</div>'
                    +   '<div class="form_element">'
                    +     '<div class="label">'
                    +       '<label>{Title}</label>'
                    +     '</div>'
                    +     '<div class="value">'
                    +       '<input type="text" name="title"/>'
                    +     '</div>'
                    +   '</div>'
                    +   '<div class="form_element submit_element">'
                    +     '<div class="value">'
                    +       '<input name="commit" type="submit" value="{Submit}" />'
                    +     '</div>'
                    +   '</div>'
                    + '</form>',
  
  dialogTableHtml:    '<form id="wym_dialog_form">'
                    +   '<div class="form_element">'
                    +     '<div class="label">'
                    +       '<label>{Caption}</label>'
                    +     '</div>'
                    +     '<div class="value">'
                    +       '<input type="text" name="caption"></textarea>'
                    +     '</div>'
                    +   '</div>'
                    +   '<div class="form_element">'
                    +     '<div class="label">'
                    +       '<label>{Summary}</label>'
                    +     '</div>'
                    +     '<div class="value">'
                    +       '<input type="text" name="summary"></textarea>'
                    +     '</div>'
                    +   '</div>'
                    +   '<div class="form_element">'
                    +     '<div class="label">'
                    +       '<label>{Number_Of_Rows}</label>'
                    +     '</div>'
                    +     '<div class="value">'
                    +       '<input type="text" name="rows"></textarea>'
                    +     '</div>'
                    +   '</div>'
                    +   '<div class="form_element">'
                    +     '<div class="label">'
                    +       '<label>{Number_Of_Cols}</label>'
                    +     '</div>'
                    +     '<div class="value">'
                    +       '<input type="text" name="cols"></textarea>'
                    +     '</div>'
                    +   '</div>'
                    +   '<div class="form_element submit_element">'
                    +     '<div class="value">'
                    +       '<input name="commit" type="submit" value="{Submit}" />'
                    +     '</div>'
                    +   '</div>'
                    + '</form>',
  
  dialogPasteHtml:    '<form id="wym_dialog_form">'
                    +   '<div class="form_element">'
                    +     '<div class="label">'
                    +       '<label>{Paste_From_Word}</label>'
                    +     '</div>'
                    +     '<div class="value">'
                    +       '<textarea name="paste"></textarea>'
                    +     '</div>'
                    +   '</div>'
                    +   '<div class="form_element submit_element">'
                    +     '<div class="value">'
                    +       '<input name="commit" type="submit" value="{Submit}" />'
                    +     '</div>'
                    +   '</div>'
                    + '</form>'
};

// -- New dialog pop-up -----------------------------------------------------
WYMeditor.editor.prototype.dialog = function( dialogType, dialogFeatures, bodyHtml ) {
  
  var body = '';
  switch(dialogType) {
    case WYMeditor.DIALOG_LINK:
      body = this._options.dialogLinkHtml;
    break;
    case WYMeditor.DIALOG_IMAGE:
      body = this._options.dialogImageHtml;
    break;
    case WYMeditor.DIALOG_TABLE:
      body = this._options.dialogTableHtml;
    break;
    case WYMeditor.DIALOG_PASTE:
      body = this._options.dialogPasteHtml;
    break;
    default:
      body = bodyHtmls;
  }
  
  this._options.dialog.html(this.replaceStrings(body));
  this._options.dialog.dialog({
    title:      this.replaceStrings(this.encloseString(dialogType)),
    modal:      true,
    width:      800,
    resizable:  false
  });
  
  WYMeditor.INIT_DIALOG(this, dialogType);
};

// -- Dialog processing -----------------------------------------------------
WYMeditor.INIT_DIALOG = function(wym, type) {
  var form = jQuery('form#wym_dialog_form');
  var selected = wym.selected();
  
  if(selected) {
    form.find('input[name="href"]').val(jQuery(selected).attr(WYMeditor.HREF));
    form.find('input[name="src"]').val(jQuery(selected).attr(WYMeditor.SRC));
    form.find('input[name="title"]').val(jQuery(selected).attr(WYMeditor.TITLE));
    form.find('input[name="alt"]').val(jQuery(selected).attr(WYMeditor.ALT));
  }
  if(wym._selected_image) {
    form.find('input[name="src"]').val(jQuery(wym._selected_image).attr(WYMeditor.SRC));
    form.find('input[name="alt"]').val(jQuery(wym._selected_image).attr(WYMeditor.ALT));
    form.find('input[name="title"]').val(jQuery(wym._selected_image).attr(WYMeditor.TITLE));
  }
  
  form.submit(function(){
    var data = { };
    var form_data = $(this).serializeArray();
    jQuery.each(form_data, function(){
      if (data[this.name] !== undefined) {
        if (!data[this.name].push) {
          data[this.name] = [data[this.name]];
        }
        data[this.name].push(this.value || '');
      } else {
        data[this.name] = this.value || '';
      }
    });
    
    switch(type){
      case WYMeditor.DIALOG_LINK:
        WYMeditor.PROCESS_DIALOG_LINK(wym, data);
      break;
      case WYMeditor.DIALOG_IMAGE:
        WYMeditor.PROCESS_DIALOG_IMAGE(wym, data);
      break;
      case WYMeditor.DIALOG_TABLE:
        WYMeditor.PROCESS_DIALOG_TABLE(wym, data);
      break;
      case WYMeditor.DIALOG_PASTE:
        WYMeditor.PROCESS_DIALOG_PASTE(wym, data);
      break;
    }
    
    wym._options.dialog.dialog('close');
    return false;
  })
}

WYMeditor.PROCESS_DIALOG_LINK = function(wym, data) {
  var sStamp = wym.uniqueStamp();
  var selected = wym.selected();
  
  //ensure that we select the link to populate the fields
  if(selected && selected.tagName && selected.tagName.toLowerCase != WYMeditor.A) {
    selected = jQuery(selected).parentsOrSelf(WYMeditor.A);
  }
  //fix MSIE selection if link image has been clicked
  if(!selected && wym._selected_image){
    selected = jQuery(wym._selected_image).parentsOrSelf(WYMeditor.A);
  }
  
  var sUrl = data['href'];
  if(sUrl.length > 0) {
    var link;
    if (selected[0] && selected[0].tagName.toLowerCase() == WYMeditor.A) {
      link = selected;
    } else {
      wym._exec(WYMeditor.CREATE_LINK, sStamp);
      link = jQuery("a[href=" + sStamp + "]", wym._doc.body);
    }
    link.attr(WYMeditor.HREF, sUrl).attr(WYMeditor.TITLE, data['title']);
  }
}

WYMeditor.PROCESS_DIALOG_IMAGE = function(wym, data) {
  var sStamp = wym.uniqueStamp();
  
  var sUrl = data['src'];
  if(sUrl.length > 0) {
    wym._exec(WYMeditor.INSERT_IMAGE, sStamp);
    
    jQuery("img[src$=" + sStamp + "]", wym._doc.body)
        .attr(WYMeditor.SRC, sUrl)
        .attr(WYMeditor.TITLE, data['title'])
        .attr(WYMeditor.ALT, data['alt']);
  }
}

WYMeditor.PROCESS_DIALOG_TABLE = function(wym, data) {
  var iRows = data['rows'];
  var iCols = data['cols'];
  if(iRows > 0 && iCols > 0) {
    var table = wym._doc.createElement(WYMeditor.TABLE);
    var newRow = null;
    var newCol = null;
    var sCaption = data['caption'];
    var newCaption = table.createCaption();
    newCaption.innerHTML = sCaption;
    for(x=0; x<iRows; x++) {
      newRow = table.insertRow(x);
      for(y=0; y<iCols; y++) {newRow.insertCell(y);}
    }
    jQuery(table).attr('summary', data['summary']);
    var node = jQuery(wym.findUp(wym.container(), WYMeditor.MAIN_CONTAINERS)).get(0);
    if(!node || !node.parentNode){
      jQuery(wym._doc.body).append(table);
    } else {
      jQuery(node).after(table);
    }
  }
}

WYMeditor.PROCESS_DIALOG_PASTE = function(wym, data) {
  wym.paste(data['paste']);
}

WYMeditor.editor.prototype.xhtml = function() {
  var html = this.parser.parse(this.html());
  var reg = /(>)(<)(\/*)/g;
  html = html.replace(reg, '$1\r\n$2$3');
  return html;
};