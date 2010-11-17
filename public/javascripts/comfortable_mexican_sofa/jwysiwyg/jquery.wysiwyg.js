/**
 * WYSIWYG - jQuery plugin 0.93
 * (koken)
 *
 * Copyright (c) 2008-2009 Juan M Martinez, 2010 Akzhan Abdulin and all contrbutors
 * http://plugins.jquery.com/project/jWYSIWYG
 *
 * Dual licensed under the MIT and GPL licenses:
 *   http://www.opensource.org/licenses/mit-license.php
 *   http://www.gnu.org/licenses/gpl.html
 *
 * $Id: $
 */

/*jslint browser: true, forin: true */

(function ($)
{
        /**
         * @constructor
         * @private
         */
        var Wysiwyg = function (element, options)
        {
                this.init(element, options);
        };

        var innerDocument = function (elts)
        {
                var element = $(elts).get(0);

                if (element.nodeName.toLowerCase() == 'iframe')
                {
                        return element.contentWindow.document;
                        /*
                         return ( $.browser.msie )
                         ? document.frames[element.id].document
                         : element.contentWindow.document // contentDocument;
                         */
                }
                return element;
        };

        var documentSelection = function ()
        {
                var element = this.get(0);

                if (element.contentWindow.document.selection)
                {
                        return element.contentWindow.document.selection.createRange().text;
                }
                else
                {
                        return element.contentWindow.getSelection().toString();
                }
        };

        $.fn.wysiwyg = function (options)
        {
                if (arguments.length > 0 && arguments[0].constructor == String)
                {
                        var action = arguments[0].toString();
                        var params = [];

                        if (action == 'enabled')
                        {
                                return this.data('wysiwyg') !== null;
                        }
                        for (var i = 1; i < arguments.length; i++)
                        {
                                params[i - 1] = arguments[i];
                        }
						var retValue = null;
						
						// .filter('textarea') is a fix for bug 29 ( http://github.com/akzhan/jwysiwyg/issues/issue/29 )
                        this.filter('textarea').each(function()
                        {
                                $.data(this, 'wysiwyg').designMode();
                                retValue = Wysiwyg[action].apply(this, params);
                        });
						return retValue;
                }

                if (this.data('wysiwyg'))
                {
                        return this;
                }

                var controls = { };

                /**
                 * If the user set custom controls, we catch it, and merge with the
                 * defaults controls later.
                 */

                if (options && options.controls)
                {
                        controls = options.controls;
                        delete options.controls;
                }

                options = $.extend({}, $.fn.wysiwyg.defaults, options);
                options.controls = $.extend(true, options.controls, $.fn.wysiwyg.controls);
                for (var control in controls)
                {
                        if (control in options.controls)
                        {
                                $.extend(options.controls[control], controls[control]);
                        }
                        else
                        {
                                options.controls[control] = controls[control];
                        }
                }

                // not break the chain
                return this.each(function ()
                {
                        new Wysiwyg(this, options);
                });
        };

        $.fn.wysiwyg.defaults = {
                html: '<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Strict//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-strict.dtd"><html xmlns="http://www.w3.org/1999/xhtml" xml:lang="en"><head><meta http-equiv="Content-Type" content="text/html; charset=UTF-8">STYLE_SHEET</head><body style="margin: 0px;">INITIAL_CONTENT</body></html>',
                formTableHtml: '<form class="wysiwyg"><fieldset><legend>Insert table</legend><label>Count of columns: <input type="text" name="colCount" value="3" /></label><label><br />Count of rows: <input type="text" name="rowCount" value="3" /></label><input type="submit" class="button" value="Insert table" /> <input type="reset" value="Cancel" /></fieldset></form>',
                formImageHtml:'<form class="wysiwyg"><fieldset><legend>Insert Image</legend><label>Image URL: <input type="text" name="url" value="http://" /></label><label>Image Title: <input type="text" name="imagetitle" value="" /></label><label>Image Description: <input type="text" name="description" value="" /></label><input type="submit" class="button" value="Insert Image" /> <input type="reset" value="Cancel" /></fieldset></form>',
                formWidth: 440,
                formHeight: 270,
                tableFiller: 'Lorem ipsum',
                css: { },
                debug: false,
                autoSave: true,
                // http://code.google.com/p/jwysiwyg/issues/detail?id=11
                rmUnwantedBr: true,
                // http://code.google.com/p/jwysiwyg/issues/detail?id=15
                brIE: true,
				iFrameClass: null,
                messages:
                {
                        nonSelection: 'select the text you wish to link'
                },
                events: { },
                controls: { },
                resizeOptions: false
        };
		
		/**
		 * Custom control support by Alec Gorge ( http://github.com/alecgorge )
		 */
		// need a global, static namespace
		$.wysiwyg = {
			addControl : function (name, settings) {
				// sample settings
				/*
				var example = {
					icon: '/path/to/icon',
					tooltip: 'my custom item',
					callback: function(selectedText, wysiwygInstance) {
						//Do whatever you want to do in here.
					}
				};
				*/
				
				var custom = {};
				custom[name] = {visible: false, custom: true, options: settings};
				
				$.extend($.fn.wysiwyg.controls, $.fn.wysiwyg.controls, custom);
			}
		};
		
        $.fn.wysiwyg.controls = {
                bold: {
                        visible: true,
                        tags: ['b', 'strong'],
                        css: {
                                fontWeight: 'bold'
                        },
                        tooltip: 'Bold'
                },
                italic: {
                        visible: true,
                        tags: ['i', 'em'],
                        css: {
                                fontStyle: 'italic'
                        },
                        tooltip: 'Italic'
                        },
                strikeThrough: {
                        visible: true,
                        tags: ['s', 'strike'],
                        css: {
                                textDecoration: 'line-through'
                        },
                        tooltip: 'Strike-through'
                },
                underline: {
                        visible: true,
                        tags: ['u'],
                        css: {
                                textDecoration: 'underline'
                        },
                        tooltip: 'Underline'
                },
                justifyLeft: {
                        visible: true,
                        groupIndex: 1,
                        css: {
                                textAlign: 'left'
                        },
                        tooltip: 'Justify Left'
                },
                justifyCenter: {
                        visible: true,
                        tags: ['center'],
                        css: {
                                textAlign: 'center'
                        },
                        tooltip: 'Justify Center'
                },
                justifyRight: {
                        visible: true,
                        css: {
                                textAlign: 'right'
                        },
                        tooltip: 'Justify Right'
                },
                justifyFull: {
                        visible: true,
                        css: {
                                textAlign: 'justify'
                        },
                        tooltip: 'Justify Full'
                },
                indent: {
                        groupIndex: 2,
                        visible: true,
                        tooltip: 'Indent'
                },
                outdent: {
                        visible: true,
                        tooltip: 'Outdent'
                },
                subscript: {
                        groupIndex: 3,
                        visible: true,
                        tags: ['sub'],
                        tooltip: 'Subscript'
                        },
                superscript: {
                        visible: true,
                        tags: ['sup'],
                        tooltip: 'Superscript'
                        },
                undo: {
                        groupIndex: 4,
                        visible: true,
                        tooltip: 'Undo'
                },
                redo: {
                        visible: true,
                        tooltip: 'Redo'
                },
                insertOrderedList: {
                        groupIndex: 5,
                        visible: true,
                        tags: ['ol'],
                        tooltip: 'Insert Ordered List'
                },
                insertUnorderedList: {
                        visible: true,
                        tags: ['ul'],
                        tooltip: 'Insert Unordered List'
                },
                insertHorizontalRule: {
                        visible: true,
                        tags: ['hr'],
                        tooltip: 'Insert Horizontal Rule'
                },
                createLink: {
                        groupIndex: 6,
                        visible: true,
                        exec: function ()
                        {
                                var selection = documentSelection.call($(this.editor));

                                if (selection && selection.length > 0)
                                {
                                        if ($.browser.msie)
                                        {
                                                this.focus();
                                                this.editorDoc.execCommand('createLink', true, null);
                                        }
                                        else
                                        {
                                                var szURL = prompt('URL', 'http://');
                                                if (szURL && szURL.length > 0)
                                                {
                                                        this.editorDoc.execCommand('unlink', false, null);
                                                        this.editorDoc.execCommand('createLink', false, szURL);
                                                }
                                        }
                                }
                                else if (this.options.messages.nonSelection)
                                {
                                        alert(this.options.messages.nonSelection);
                                }
                        },
                        tags: ['a'],
                        tooltip: 'Create link'
                },
                insertImage: {
                        visible: true,
                        exec: function ()
                        {
                                var self = this;
                                if ($.modal)
                                {
                                        $.modal($.fn.wysiwyg.defaults.formImageHtml, {
                                                onShow: function(dialog)
                                                {
                                                        $('input:submit', dialog.data).click(function(e)
                                                        {
                                                                e.preventDefault();
                                                                var szURL = $('input[name="url"]', dialog.data).val();
                                                                var title = $('input[name="imagetitle"]', dialog.data).val();
                                                                var description = $('input[name="description"]', dialog.data).val();
                                                                var img="<img src='" + szURL + "' title='" + title + "' alt='" + description + "' />";
                                                                self.insertHtml(img);
                                                                $.modal.close();
                                                        });
                                                        $('input:reset', dialog.data).click(function(e)
                                                        {
                                                                e.preventDefault();
                                                                $.modal.close();
                                                        });
                                                },
                                                maxWidth: $.fn.wysiwyg.defaults.formWidth,
                                                maxHeight: $.fn.wysiwyg.defaults.formHeight,
                                                overlayClose: true
                                        });
                                }
                                else
                                {
                                     if ($.fn.dialog){
                                        var dialog = $($.fn.wysiwyg.defaults.formImageHtml).appendTo('body');
                                        dialog.dialog({
                                            modal: true,
                                            width: $.fn.wysiwyg.defaults.formWidth,
                                            height: $.fn.wysiwyg.defaults.formHeight,
                                            open: function(ev, ui)
                                            {
                                                 $('input:submit', $(this)).click(function(e)
                                                 {
                                                       e.preventDefault();
                                                       var szURL = $('input[name="url"]', dialog).val();
                                                       var title = $('input[name="imagetitle"]', dialog).val();
                                                       var description = $('input[name="description"]', dialog).val();
                                                       var img="<img src='" + szURL + "' title='" + title + "' alt='" + description + "' />";
                                                       self.insertHtml(img);
                                                       $(dialog).dialog("close");
                                                 });
                                                 $('input:reset', $(this)).click(function(e)
                                                        {
                                                                e.preventDefault();
                                                                $(dialog).dialog("close");
                                                        });
                                            },
                                            close: function(ev, ui){
        		                                  $(this).dialog("destroy");

                                            }
                                        });
                                    }
                                    else
                                    {
                                        if ($.browser.msie)
    	                                {
    	                                        this.focus();
    	                                        this.editorDoc.execCommand('insertImage', true, null);
    	                                }
    	                                else
    	                                {
    	                                        var szURL = prompt('URL', 'http://');
    	                                        if (szURL && szURL.length > 0)
    	                                        {
    	                                                this.editorDoc.execCommand('insertImage', false, szURL);
    	                                        }
    	                                }
                                    }


                                }

                        },
                        tags: ['img'],
                        tooltip: 'Insert image'
                },
                insertTable: {
                        visible: true,
                        exec: function ()
                        {
                                var self = this;
                                if ($.fn.modal)
                                {
                                        $.modal($.fn.wysiwyg.defaults.formTableHtml, {
                                                onShow: function(dialog)
                                                {
                                                        $('input:submit', dialog.data).click(function(e)
                                                        {
                                                                e.preventDefault();
                                                                var rowCount = $('input[name="rowCount"]', dialog.data).val();
                                                                var colCount = $('input[name="colCount"]', dialog.data).val();
                                                                self.insertTable(colCount, rowCount, $.fn.wysiwyg.defaults.tableFiller);
                                                                $.modal.close();
                                                        });
                                                        $('input:reset', dialog.data).click(function(e)
                                                        {
                                                                e.preventDefault();
                                                                $.modal.close();
                                                        });
                                                },
                                                maxWidth: $.fn.wysiwyg.defaults.formWidth,
                                                maxHeight: $.fn.wysiwyg.defaults.formHeight,
                                                overlayClose: true
                                        });
                                }
                                else
                                {
                                    if ($.fn.dialog){
                                        var dialog = $($.fn.wysiwyg.defaults.formTableHtml).appendTo('body');
                                        dialog.dialog({
                                            modal: true,
                                            width: $.fn.wysiwyg.defaults.formWidth,
                                            height: $.fn.wysiwyg.defaults.formHeight,
                                            open: function(event, ui){
                                                 $('input:submit', $(this)).click(function(e)
                                                 {
                                                        e.preventDefault();
                                                        var rowCount = $('input[name="rowCount"]', dialog).val();
                                                        var colCount = $('input[name="colCount"]', dialog).val();
                                                        self.insertTable(colCount, rowCount, $.fn.wysiwyg.defaults.tableFiller);
                                                        $(dialog).dialog("close");
                                                 });
                                                 $('input:reset', $(this)).click(function(e)
                                                        {
                                                                e.preventDefault();
                                                                $(dialog).dialog("close");
                                                        });
                                            },
                                            close: function(event, ui){
        		                                  $(this).dialog("destroy");

                                            }
                                        });
                                    }
                                    else
                                    {
                                            var colCount = prompt('Count of columns', '3');
                                            var rowCount = prompt('Count of rows', '3');
                                            this.insertTable(colCount, rowCount, $.fn.wysiwyg.defaults.tableFiller);
                                    }
                                }
                        },
                        tags: ['table'],
                        tooltip: 'Insert table'
                },
                h1: {
                        visible: true,
                        groupIndex: 7,
                        className: 'h1',
                        command: ($.browser.msie || $.browser.safari) ? 'FormatBlock' : 'heading',
                        'arguments': ($.browser.msie || $.browser.safari) ? '<h1>' : 'h1',
                        tags: ['h1'],
                        tooltip: 'Header 1'
                },
                h2: {
                        visible: true,
                        className: 'h2',
                        command: ($.browser.msie || $.browser.safari)  ? 'FormatBlock' : 'heading',
                        'arguments': ($.browser.msie || $.browser.safari) ? '<h2>' : 'h2',
                        tags: ['h2'],
                        tooltip: 'Header 2'
                },
                h3: {
                        visible: true,
                        className: 'h3',
                        command: ($.browser.msie || $.browser.safari) ? 'FormatBlock' : 'heading',
                        'arguments': ($.browser.msie || $.browser.safari) ? '<h3>' : 'h3',
                        tags: ['h3'],
                        tooltip: 'Header 3'
                },
                cut: {
                        groupIndex: 8,
                        visible: false,
                        tooltip: 'Cut'
                        },
                copy: {
                        visible: false,
                        tooltip: 'Copy'
                },
                paste: {
                        visible: false,
                        tooltip: 'Paste'
                },
                increaseFontSize: {
                        groupIndex: 9,
                        visible: false && !($.browser.msie),
                        tags: ['big'],
                        tooltip: 'Increase font size'
                },
                decreaseFontSize: {
                        visible: false && !($.browser.msie),
                        tags: ['small'],
                        tooltip: 'Decrease font size'
                },
                removeFormat: {
                         visible: true,
                         exec: function ()
                         {
                                if ($.browser.msie)
                                {
                                        this.focus();
                                }
                                this.editorDoc.execCommand('formatBlock', false, '<P>'); // remove headings
                                this.editorDoc.execCommand('removeFormat', false, null);
                                this.editorDoc.execCommand('unlink', false, null);
                         },
                         tooltip: 'Remove formatting'
                },
                html: {
                        groupIndex: 10,
                        visible: false,
                        exec: function ()
                        {
                                if (this.viewHTML)
                                {
                                        this.setContent($(this.original).val());
                                        $(this.original).hide();
										$(this.editor).show();
                                }
                                else
                                {
									    var $ed = $(this.editor);
                                        this.saveContent();
                                        $(this.original).css({
                                                width:  $(this.element).outerWidth() - 6,
												height: $(this.element).height() - $(this.panel).height() - 6,
												resize: 'none'
										}).show();
										$ed.hide();
                                }

                                this.viewHTML = !(this.viewHTML);
                         },
                         tooltip: 'View source code'
                },
                rtl: {
                         visible : false,
                         exec    : function()
                         {
                                 var selection = $(this.editor).documentSelection();
                                 if ($("<div />").append(selection).children().length > 0) 
                                 {
                                         selection = $(selection).attr("dir", "rtl");
                                 }
                                 else
                                 {
                                         selection = $("<div />").attr("dir", "rtl").append(selection);
                                 }
                                 this.editorDoc.execCommand('inserthtml', false, $("<div />").append(selection).html());
                        },
                        tooltip : "Right to Left"
                },
                ltr: {
                        visible : false,
                        exec    : function()
                        {
                                var selection = $(this.editor).documentSelection();
                                if ($("<div />").append(selection).children().length > 0) 
                                {
                                        selection = $(selection).attr("dir", "ltr");
                                }
                                else
                                {
                                        selection = $("<div />").attr("dir", "ltr").append(selection);
                                }
                                this.editorDoc.execCommand('inserthtml', false, $("<div />").append(selection).html());
                        },
                        tooltip : "Left to Right"
               }
        };

        $.extend(Wysiwyg, {
                insertImage: function (szURL, attributes)
                {
                        var self = $.data(this, 'wysiwyg');
                        if (self.constructor == Wysiwyg && szURL && szURL.length > 0)
                        {
                                if ($.browser.msie)
                                {
                                        self.focus();
                                }
                                if (attributes)
                                {
                                        self.editorDoc.execCommand('insertImage', false, '#jwysiwyg#');
                                        var img = self.getElementByAttributeValue('img', 'src', '#jwysiwyg#');

                                        if (img)
                                        {
                                                img.src = szURL;

                                                for (var attribute in attributes)
                                                {
                                                        img.setAttribute(attribute, attributes[attribute]);
                                                }
                                        }
                                }
                                else
                                {
                                        self.editorDoc.execCommand('insertImage', false, szURL);
                                }
                        }
		                return this;
                },

                createLink: function (szURL)
                {
                        var self = $.data(this, 'wysiwyg');

                        if (self.constructor == Wysiwyg && szURL && szURL.length > 0)
                        {
                                var selection = documentSelection.call($(self.editor));

                                if (selection && selection.length > 0)
                                {
                                        if ($.browser.msie)
                                        {
                                                self.focus();
                                        }
                                        self.editorDoc.execCommand('unlink', false, null);
                                        self.editorDoc.execCommand('createLink', false, szURL);
                                }
                                else if (self.options.messages.nonSelection)
                                {
                                        alert(self.options.messages.nonSelection);
                                }
                        }
						return this;
                },

                insertHtml: function (szHTML)
                {
                        var self = $.data(this, 'wysiwyg');
                        self.insertHtml(szHTML);
						return this;
                },

                insertTable: function(colCount, rowCount, filler)
                {
                        $.data(this, 'wysiwyg').insertTable(colCount, rowCount, filler);
						return this;
                },

                getContent: function()
                {
					    var self = $.data(this, 'wysiwyg');
						return self.getContent();
                },

                setContent: function (newContent)
                {
					    var self = $.data(this, 'wysiwyg');
                        self.setContent(newContent);
                        self.saveContent();
						return this;
                },

                clear: function ()
                {
                        var self = $.data(this, 'wysiwyg');
                        self.setContent('');
                        self.saveContent();
						return this;
                },

                removeFormat: function ()
                {
                        var self = $.data(this, 'wysiwyg');
                        self.removeFormat();
						return this;
                },

                save: function ()
                {
                        var self = $.data(this, 'wysiwyg');
                        self.saveContent();
						return this;
                },

                "document": function()
                {
                        var self = $.data(this, 'wysiwyg');
                        return $(self.editorDoc);
                },

                destroy: function ()
                {
                        var self = $.data(this, 'wysiwyg');
                        self.destroy();
						return this;
                }
        });

        var addHoverClass = function()
        {
                $(this).addClass('wysiwyg-button-hover');
        };
        var removeHoverClass = function()
        {
                $(this).removeClass('wysiwyg-button-hover');
        };

        $.extend(Wysiwyg.prototype, {
                original: null,
                options: {
                },

                element: null,
				rangeSaver: null,
                editor: null,

                removeFormat: function ()
                {
                        if ($.browser.msie)
                        {
                                this.focus();
                        }
                        this.editorDoc.execCommand('removeFormat', false, null);
                        this.editorDoc.execCommand('unlink', false, null);
						return this;
                },
                destroy: function ()
                {
                        // Remove bindings
                        var $form = $(this.element).closest('form');
                        $form.unbind('submit', this.autoSaveFunction)
                             .unbind('reset', this.resetFunction);
                        $(this.element).remove();
                        $.removeData(this.original, 'wysiwyg');
                        $(this.original).show();
						return this;
                },
                focus: function ()
                {
                        this.editor.get(0).contentWindow.focus();
						return this;
                },

                init: function (element, options)
                {
                        var self = this;

                        this.editor = element;
                        this.options = options || {
                        };

                        $.data(element, 'wysiwyg', this);

                        var newX = element.width || element.clientWidth || 0;
                        var newY = element.height || element.clientHeight || 0;

                        if (element.nodeName.toLowerCase() == 'textarea')
                        {
                                this.original = element;

                                if (newX === 0 && element.cols)
                                {
                                        newX = (element.cols * 8) + 21;
										
										// fix for issue 30 ( http://github.com/akzhan/jwysiwyg/issues/issue/30 )
										element.cols = 1;
                                }
                                if (newY === 0 && element.rows)
                                {
                                        newY = (element.rows * 16) + 16;

										// fix for issue 30 ( http://github.com/akzhan/jwysiwyg/issues/issue/30 )
										element.rows = 1;
                                }
                                this.editor = $(location.protocol == 'https:' ? '<iframe src="javascript:false;"></iframe>' : '<iframe></iframe>').attr('frameborder', '0');
								if (options.iFrameClass)
								{
									this.editor.addClass(options.iFrameClass);
								}
								else
								{
                                    this.editor.css({
                                        minHeight: (newY - 6).toString() + 'px',
										
										// fix for issue 12 ( http://github.com/akzhan/jwysiwyg/issues/issue/12 )
                                        width: (newX > 50) ? (newX - 8).toString() + 'px' : ''
                                    });
                                    if ($.browser.msie)
                                    {
                                        this.editor.css('height', newY.toString() + 'px');
                                    }
								}

                                /**
                                 * http://code.google.com/p/jwysiwyg/issues/detail?id=96
                                 */
                                this.editor.attr('tabindex', $(element).attr('tabindex'));
                        }

                        var panel = this.panel = $('<ul role="menu" class="panel"></ul>');

                        this.appendControls();
                        this.element = $('<div></div>').addClass('wysiwyg').append(panel).append($('<div><!-- --></div>').css({
                            clear: 'both'
                        })).append(this.editor);

						if (!options.iFrameClass)
						{
                            this.element.css({
                               width: (newX > 0) ? newX.toString() + 'px' : '100%'
                            });
						}

                        $(element).hide().before(this.element);

                        this.viewHTML = false;
                        this.initialHeight = newY - 8;

                        /**
                         * @link http://code.google.com/p/jwysiwyg/issues/detail?id=52
                         */
                        this.initialContent = $(element).val();
                        this.initFrame();

                        this.autoSaveFunction = function ()
                        {
                                self.saveContent();
                        };

                        this.resetFunction = function()
                        {
                                self.setContent(self.initialContent);
                                self.saveContent();
                        }

                        if(this.options.resizeOptions && $.fn.resizable)
                        {
                                this.element.resizable($.extend(true, {
                                        alsoResize: this.editor
                                }, this.options.resizeOptions));
                        }

                        var $form = $(element).closest('form');

                        if (this.options.autoSave)
                        {                            
                                $form.submit(self.autoSaveFunction);
                        }

                        $form.bind('reset', self.resetFunction);
                },

                initFrame: function ()
                {
                        var self = this;
                        var style = '';

                        /**
                         * @link http://code.google.com/p/jwysiwyg/issues/detail?id=14
                         */
                        if (this.options.css && this.options.css.constructor == String)
                        {
                                style = '<link rel="stylesheet" type="text/css" media="screen" href="' + this.options.css + '" />';
                        }

                        this.editorDoc = innerDocument(this.editor);
                        this.editorDoc_designMode = false;

                        this.designMode();

                        this.editorDoc.open();
                        this.editorDoc.write(
                        this.options.html
                        /**
                         * @link http://code.google.com/p/jwysiwyg/issues/detail?id=144
                         */
                        .replace(/INITIAL_CONTENT/, function ()
                        {
                                return self.initialContent;
                        }).replace(/STYLE_SHEET/, function ()
                        {
                                return style;
                        }));
                        this.editorDoc.close();

                        if ($.browser.msie)
                        {
                                /**
                                 * Remove the horrible border it has on IE.
                                 */
                                window.setTimeout(function ()
                                {
                                        $(self.editorDoc.body).css('border', 'none');
                                }, 0);
                        }

                        $(this.editorDoc).click(function (event)
                        {
                                self.checkTargets(event.target ? event.target : event.srcElement);
                        });

                        /**
                         * @link http://code.google.com/p/jwysiwyg/issues/detail?id=20
                         */
                        $(this.original).focus(function ()
                        {
						        if ($(this).filter(':visible'))
								{
								        return;
								}
                                self.focus();
                        });

                        if (!$.browser.msie)
                        {
                                $(this.editorDoc).keydown(function (event)
                                {
                                        if (event.ctrlKey)
                                        {
                                                switch (event.keyCode)
                                                {
                                                case 66:
                                                        // Ctrl + B
                                                        this.execCommand('Bold', false, false);
                                                        return false;
                                                case 73:
                                                        // Ctrl + I
                                                        this.execCommand('Italic', false, false);
                                                        return false;
                                                case 85:
                                                        // Ctrl + U
                                                        this.execCommand('Underline', false, false);
                                                        return false;
                                                }
                                        }
                                        return true;
                                });
                        }
                        else if (this.options.brIE)
                        {
                                $(this.editorDoc).keydown(function (event)
                                {
                                        if (event.keyCode == 13)
                                        {
                                                var rng = self.getRange();
                                                rng.pasteHTML('<br />');
                                                rng.collapse(false);
                                                rng.select();
                                                return false;
                                        }
                                        return true;
                                });
                        }

                        if (this.options.autoSave)
                        {
                                /**
                                 * @link http://code.google.com/p/jwysiwyg/issues/detail?id=11
                                 */
                                var handler = function () {
                                    self.saveContent();
                                };
                                $(this.editorDoc).keydown(handler).keyup(handler).mousedown(handler).bind($.support.noCloneEvent ? "input" : "paste", handler);

                        }

                        if (this.options.css)
                        {
                                window.setTimeout(function ()
                                {
                                        if (self.options.css.constructor == String)
                                        {
                                                /**
                                                 * $(self.editorDoc)
                                                 * .find('head')
                                                 * .append(
                                                 *	 $('<link rel="stylesheet" type="text/css" media="screen" />')
                                                 *	 .attr('href', self.options.css)
                                                 * );
                                                 */
                                        }
                                        else
                                        {
                                                $(self.editorDoc).find('body').css(self.options.css);
                                        }
                                }, 0);
                        }

                        if (this.initialContent.length === 0)
                        {
                                this.setContent('<p>initial content</p>');
                        }

                        $.each(this.options.events, function(key, handler)
                        {
                                $(self.editorDoc).bind(key, handler);
                        });
						
						// restores selection properly on focus
						$(self.editor).blur(function() {
							self.rangeSaver = self.getInternalRange();
						});

						$(this.editorDoc.body).addClass('wysiwyg');
                        if(this.options.events && this.options.events.save) {
                            var handler = this.options.events.save;
                            $(self.editorDoc).bind('keyup', handler);
                            $(self.editorDoc).bind('change', handler);
                            if($.support.noCloneEvent) {
                                $(self.editorDoc).bind("input", handler);
                            } else {
                                $(self.editorDoc).bind("paste", handler);
                                $(self.editorDoc).bind("cut", handler);
                            }
                        }
                },
				
				focusEditor: function () {
					//console.log(this.editorDoc.body.focus());//.focus();
					if (this.rangeSaver != null) {
						if (window.getSelection) { //non IE and there is already a selection
							var s = window.getSelection();
							if (s.rangeCount > 0) s.removeAllRanges();
							s.addRange(savedRange);
						}
						else if (document.createRange) { //non IE and no selection
							window.getSelection().addRange(savedRange);
						}
						else if (document.selection) { //IE
							savedRange.select();
						}
					}					
				},

				execute: function (command, arg) {
					if(typeof(arg) == "undefined") arg = null;
					this.editorDoc.execCommand(command, false, arg);
				},

                designMode: function ()
                {
                        var attempts = 3;
                        var runner;
                        var self = this;
                        var doc  = this.editorDoc;
                        runner = function()
                        {
                                if (innerDocument(self.editor) !== doc)
                                {
                                        self.initFrame();
                                        return;
                                }
                                try
                                {
                                        doc.designMode = 'on';
                                }
                                catch (e)
                                {
                                }
                                attempts--;
                                if (attempts > 0 && $.browser.mozilla)
                                {
                                        setTimeout(runner, 100);
                                }
                        };
                        runner();
                        this.editorDoc_designMode = true;
                },

                getSelection: function ()
                {
                        return (window.getSelection) ? window.getSelection() : document.selection;
                },


                getInternalSelection: function ()
                {
                        return (this.editor[0].contentWindow.getSelection) ? this.editor[0].contentWindow.getSelection() : this.editor[0].contentDocument.selection;
                },

                getRange: function ()
                {
                        var selection = this.getSelection();
						
                        if (!selection)
                        {
                                return null;
                        }

                        return (selection.rangeCount > 0) ? selection.getRangeAt(0) : (selection.createRange ? selection.createRange() : null);
                },

                getInternalRange: function ()
                {
                        var selection = this.getInternalSelection();
						
                        if (!selection)
                        {
                                return null;
                        }

                        return (selection.rangeCount > 0) ? selection.getRangeAt(0) : (selection.createRange ? selection.createRange() : null);
                },

                getContent: function ()
                {
                        return $(innerDocument(this.editor)).find('body').html();
                },

                setContent: function (newContent)
                {
                        $(innerDocument(this.editor)).find('body').html(newContent);
						return this;
                },
                insertHtml: function (szHTML)
                {
                        if (szHTML && szHTML.length > 0)
                        {
                                if ($.browser.msie)
                                {
                                        this.focus();
                                        this.editorDoc.execCommand('insertImage', false, '#jwysiwyg#');
                                        var img = this.getElementByAttributeValue('img', 'src', '#jwysiwyg#');
                                        if (img)
                                        {
                                                $(img).replaceWith(szHTML);
                                        }
                                }
                                else
                                {
                                        this.editorDoc.execCommand('insertHTML', false, szHTML);
                                }
                        }
						return this;
                },
                insertTable: function(colCount, rowCount, filler)
                {
                        if (isNaN(rowCount) || isNaN(colCount) || rowCount === null || colCount === null)
                        {
                                return;
                        }
                        colCount = parseInt(colCount, 10);
                        rowCount = parseInt(rowCount, 10);
                        if (filler === null)
                        {
                                filler = '&nbsp;';
                        }
                        filler = '<td>' + filler + '</td>';
                        var html = ['<table border="1" style="width: 100%;"><tbody>'];
                        for (var i = rowCount; i > 0; i--)
                        {
                                html.push('<tr>');
                                for (var j = colCount; j > 0; j--)
                                {
                                        html.push(filler);
                                }
                                html.push('</tr>');
                        }
                        html.push('</tbody></table>');
                        return this.insertHtml(html.join(''));
                },
                saveContent: function ()
                {
                        if (this.original)
                        {
                                var content = this.getContent();

                                if (this.options.rmUnwantedBr)
                                {
                                        content = (content.substr(-4) == '<br>') ? content.substr(0, content.length - 4) : content;
                                }

                                $(this.original).val(content);
                                if(this.options.events && this.options.events.save) {
                                    this.options.events.save.call(this);
                                }
                        }
						return this;
                },

                withoutCss: function ()
                {
                        if ($.browser.mozilla)
                        {
                                try
                                {
                                        this.editorDoc.execCommand('styleWithCSS', false, false);
                                }
                                catch (e)
                                {
                                        try
                                        {
                                                this.editorDoc.execCommand('useCSS', false, true);
                                        }
                                        catch (e2)
                                        {
                                        }
                                }
                        }
						return this;
                },

                appendMenuCustom: function (name, options)
                {
                        var self = this;

						$(window).bind("wysiwyg-trigger-"+name, options.callback);
						
                        return $('<li role="menuitem" UNSELECTABLE="on"><img src="' + options.icon + '" class="jwysiwyg-custom-icon" />' + (name) + '</li>')
									.addClass("custom-command-"+name)
									.addClass("jwysiwyg-custom-command")
									.addClass(name)
									.attr('title', options.tooltip)
									.hover(addHoverClass, removeHoverClass)
									.click(function () {
										self.triggerCallback(name);
									})
									.appendTo(this.panel);
                },
				
				triggerCallback : function (name) {
					$(window).trigger("wysiwyg-trigger-"+name, [
						this.getInternalRange(),
						this,
						this.getInternalSelection()
					]);
					$(".custom-command-"+name, this.panel).blur();
					this.focusEditor();
				},

                appendMenu: function (cmd, args, className, fn, tooltip)
                {
                        var self = this;
                        args = args || [];

                        return $('<li role="menuitem" UNSELECTABLE="on">' + (className || cmd) + '</li>').addClass(className || cmd).attr('title', tooltip).hover(addHoverClass, removeHoverClass).click(function ()
                        {
                                if (fn)
                                {
                                        fn.apply(self);
                                }
                                else
                                {
                                        self.focus();
                                        self.withoutCss();
                                        self.editorDoc.execCommand(cmd, false, args);
                                }
                                if (self.options.autoSave)
                                {
                                        self.saveContent();
                                }
                                this.blur();
								self.focusEditor();
                        }).appendTo(this.panel);
                },

                appendMenuSeparator: function ()
                {
                        return $('<li role="separator" class="separator"></li>').appendTo(this.panel);
                },
                parseControls: function() {
                    if(this.options.parseControls) {
                        return this.options.parseControls.call(this);
                    }
                    return this.options.controls;
                },
                appendControls: function ()
                {
                        var controls = this.parseControls();
                        var currentGroupIndex  = 0;
                        var hasVisibleControls = true; // to prevent separator before first item
                        for (var name in controls)
                        {
                                var control = controls[name];                            
								if (control.groupIndex && currentGroupIndex != control.groupIndex)
                                {
                                        currentGroupIndex = control.groupIndex;
                                        hasVisibleControls = false;
                                }
                                if (!control.visible)
                                {
                                        continue;
                                }
                                if (!hasVisibleControls)
                                {
                                        this.appendMenuSeparator();
                                        hasVisibleControls = true;
                                }
								
								if(control.custom) {
									this.appendMenuCustom(name, control.options);
								}
								else {
									this.appendMenu(
											control.command || name,
											control['arguments'] || '',
											control.className || control.command || name || 'empty',
											control.exec,
											control.tooltip || control.command || name || ''
									);
								}
                        }
                },

                checkTargets: function (element)
                {
                        for (var name in this.options.controls)
                        {
                                var control = this.options.controls[name];
                                var className = control.className || control.command || name || 'empty';

                                $('.' + className, this.panel).removeClass('active');

                                if (control.tags || (control.options && control.options.tags))
                                {
										var tags = control.tags || (control.options && control.options.tags);
                                        var elm = element;
                                        do
                                        {
                                               if (elm.nodeType != 1)
                                                {
                                                        break;
                                                }

                                                if ($.inArray(elm.tagName.toLowerCase(), tags) != -1)
                                                {
                                                        $('.' + className, this.panel).addClass('active');
                                                }
                                        } while ((elm = elm.parentNode));
                                }

                                if (control.css || (control.options && control.options.css))
                                {
										var css = control.css || (control.options && control.options.css);
                                       var el = $(element);

                                        do
                                        {
                                                if (el[0].nodeType != 1)
                                                {
                                                        break;
                                                }

                                                for (var cssProperty in css)
                                                {
                                                        if (el.css(cssProperty).toString().toLowerCase() == css[cssProperty])
                                                        {
                                                                $('.' + className, this.panel).addClass('active');
                                                        }
                                                }
                                        } while ((el = el.parent()));
                                }
                        }
                },

                getElementByAttributeValue: function (tagName, attributeName, attributeValue)
                {
                        var elements = this.editorDoc.getElementsByTagName(tagName);

                        for (var i = 0; i < elements.length; i++)
                        {
                                var value = elements[i].getAttribute(attributeName);

                                if ($.browser.msie)
                                { /** IE add full path, so I check by the last chars. */
                                        value = value.substr(value.length - attributeValue.length);
                                }

                                if (value == attributeValue)
                                {
                                        return elements[i];
                                }
                        }

                        return false;
                }
        });
})(jQuery);
