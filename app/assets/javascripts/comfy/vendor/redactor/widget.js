(function($R)
{
    $R.add('plugin', 'widget', {
        translations: {
            en: {
                "widget": "Widget",
                "widget-html-code": "Widget HTML Code"
            }
        },
        modals: {
            'widget':
                '<form action=""> \
                    <div class="form-item"> \
                        <label for="modal-widget-input">## widget-html-code ##</label> \
                        <textarea id="modal-widget-input" name="widget" style="height: 200px;"></textarea> \
                    </div> \
                </form>'
        },
        init: function(app)
        {
            this.app = app;
            this.lang = app.lang;
            this.opts = app.opts;
            this.toolbar = app.toolbar;
            this.component = app.component;
            this.insertion = app.insertion;
            this.inspector = app.inspector;
            this.selection = app.selection;
        },
        // messages
        onmodal: {
            widget: {
                opened: function($modal, $form)
                {
                    $form.getField('widget').focus();

                    if (this.$currentItem)
                    {
                        var code = decodeURI(this.$currentItem.attr('data-widget-code'));
                        $form.getField('widget').val(code);
                    }
                },
                insert: function($modal, $form)
                {
                    var data = $form.getData();
                    this._insert(data);
                }
            }
        },
        oncontextbar: function(e, contextbar)
        {
            var data = this.inspector.parse(e.target)
            if (!data.isFigcaption() && data.isComponentType('widget'))
            {
                var node = data.getComponent();
                var buttons = {
                    "edit": {
                        title: this.lang.get('edit'),
                        api: 'plugin.widget.open',
                        args: node
                    },
                    "remove": {
                        title: this.lang.get('delete'),
                        api: 'plugin.widget.remove',
                        args: node
                    }
                };

                contextbar.set(e, node, buttons, 'bottom');
            }
        },
        onbutton: {
            widget: {
                observe: function(button)
                {
                    this._observeButton(button);
                }
            }
        },

        // public
        start: function()
        {
            var obj = {
                title: this.lang.get('widget'),
                api: 'plugin.widget.open',
                observe: 'widget'
            };

            var $button = this.toolbar.addButton('widget', obj);
            $button.setIcon('<i class="re-icon-widget"></i>');
        },
        open: function()
		{
            this.$currentItem = this._getCurrent();

            var options = {
                title: this.lang.get('widget'),
                width: '600px',
                name: 'widget',
                handle: 'insert',
                commands: {
                    insert: { title: (this.$currentItem) ? this.lang.get('save') : this.lang.get('insert') },
                    cancel: { title: this.lang.get('cancel') }
                }
            };

            this.app.api('module.modal.build', options);
		},
        remove: function(node)
        {
            this.component.remove(node);
        },

        // private
		_getCurrent: function()
		{
    		var current = this.selection.getCurrent();
    		var data = this.inspector.parse(current);
    		if (data.isComponentType('widget'))
    		{
        		return this.component.build(data.getComponent());
    		}
		},
		_insert: function(data)
		{
    		this.app.api('module.modal.close');

    		if (data.widget.trim() === '')
    		{
        	    return;
    		}

    		var html = (this._isHtmlString(data.widget)) ? data.widget : document.createTextNode(data.widget);
            var $component = this.component.create('widget', html);
            $component.attr('data-widget-code', encodeURI(data.widget.trim()));
    		this.insertion.insertHtml($component);

		},
        _isHtmlString: function(html)
        {
            return !(typeof html === 'string' && !/^\s*<(\w+|!)[^>]*>/.test(html));
        },
		_observeButton: function(button)
		{
    		var current = this.selection.getCurrent();
    		var data = this.inspector.parse(current);

    		if (data.isComponentType('table')) button.disable();
    		else button.enable();
		}
    });
})(Redactor);