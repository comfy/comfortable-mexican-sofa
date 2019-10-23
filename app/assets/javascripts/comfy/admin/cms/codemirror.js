"use strict";

(function () {
  var codeMirrorInstances = [];
  window.CMS.codemirror = {
    init: function init() {
      var root = arguments.length > 0 && arguments[0] !== undefined ? arguments[0] : document;
      var _iteratorNormalCompletion = true;
      var _didIteratorError = false;
      var _iteratorError = undefined;

      try {
        for (var _iterator = root.querySelectorAll('textarea[data-cms-cm-mode]')[Symbol.iterator](), _step; !(_iteratorNormalCompletion = (_step = _iterator.next()).done); _iteratorNormalCompletion = true) {
          var textarea = _step.value;
          var codemirror = CodeMirror.fromTextArea(textarea, {
            mode: textarea.dataset.cmsCmMode,
            tabSize: 2,
            lineWrapping: true,
            autoCloseTags: true,
            lineNumbers: true,
            viewportMargin: Infinity
          });
          codeMirrorInstances.push(codemirror);
        }
      } catch (err) {
        _didIteratorError = true;
        _iteratorError = err;
      } finally {
        try {
          if (!_iteratorNormalCompletion && _iterator.return != null) {
            _iterator.return();
          }
        } finally {
          if (_didIteratorError) {
            throw _iteratorError;
          }
        }
      }

      var tabsRoot = root.id === 'form-fragments' ? root : root.querySelector('#form-fragments');
      jQuery(tabsRoot).find('a[data-toggle="tab"]').on('shown.bs.tab', function () {
        var _iteratorNormalCompletion2 = true;
        var _didIteratorError2 = false;
        var _iteratorError2 = undefined;

        try {
          for (var _iterator2 = codeMirrorInstances[Symbol.iterator](), _step2; !(_iteratorNormalCompletion2 = (_step2 = _iterator2.next()).done); _iteratorNormalCompletion2 = true) {
            var codemirror = _step2.value;
            codemirror.refresh();
          }
        } catch (err) {
          _didIteratorError2 = true;
          _iteratorError2 = err;
        } finally {
          try {
            if (!_iteratorNormalCompletion2 && _iterator2.return != null) {
              _iterator2.return();
            }
          } finally {
            if (_didIteratorError2) {
              throw _iteratorError2;
            }
          }
        }
      });
    },
    dispose: function dispose() {
      var _iteratorNormalCompletion3 = true;
      var _didIteratorError3 = false;
      var _iteratorError3 = undefined;

      try {
        for (var _iterator3 = codeMirrorInstances[Symbol.iterator](), _step3; !(_iteratorNormalCompletion3 = (_step3 = _iterator3.next()).done); _iteratorNormalCompletion3 = true) {
          var codemirror = _step3.value;
          codemirror.toTextArea();
        }
      } catch (err) {
        _didIteratorError3 = true;
        _iteratorError3 = err;
      } finally {
        try {
          if (!_iteratorNormalCompletion3 && _iterator3.return != null) {
            _iterator3.return();
          }
        } finally {
          if (_didIteratorError3) {
            throw _iteratorError3;
          }
        }
      }

      codeMirrorInstances.length = 0;
    }
  };
})();
