(function($R)
{
    $R.add('plugin', 'beyondgrammar', {
        init: function(app)
        {
            this.app = app;
            this.opts = app.opts;
            this.editor = app.editor;
            this.cleaner = app.cleaner;
        },
        // messages
        onoriginalblur: function(e)
        {
            var $target = $R.dom(e.target);
            if ($target.hasClass('pwa-suggest'))
            {
                e.preventDefault();
                this.app.stopBlur = true;
                return;
            }

            this.app.stopBlur = false;
        },
        onsource: {
            closed: function()
            {
                this.editor.focus();
                this._activate();
            }
        },
        // public
        start: function()
        {
            this.GrammarChecker = this._getGrammarChecker();
            if (!this.opts.beyondgrammar || !this.GrammarChecker) return;

            // add cleaner rules
            this.cleaner.addUnconvertRules('spellcheck', function($wrapper)
            {
                $wrapper.find('.pwa-mark').unwrap();
            });

            // activate
            this._activate();
        },

        // private
        _activate: function()
        {
            // editor
            var $editor = this.editor.getElement();
            $editor.attr('spellcheck', false);

            var checker = new this.GrammarChecker($editor.get(), this.opts.beyondgrammar.service, this.opts.beyondgrammar.grammar);
            checker.init().then(function()
            {
                //grammar checker is inited and can be activate
                checker.activate();
            });
        },
        _getGrammarChecker: function()
        {
            return (typeof window["BeyondGrammar"] === 'undefined') ? false : window["BeyondGrammar"]["GrammarChecker"];
        }
    });
})(Redactor);