"use strict";

(function () {
  var Rails = window.Rails;
  var DATA_ID_ATTRIBUTE = 'data-id';
  var sortableStore = {
    get: function get(sortable) {
      return Array.from(sortable.el.children, function (el) {
        return el.getAttribute(DATA_ID_ATTRIBUTE);
      });
    },
    set: function set(sortable) {
      fetch("".concat(CMS.current_path, "/reorder"), {
        body: JSON.stringify({
          order: sortable.toArray()
        }),
        headers: {
          'Content-Type': 'application/json',
          'X-CSRF-Token': Rails.csrfToken()
        },
        credentials: 'same-origin',
        method: 'PUT'
      });
    }
  };
  var sortableInstances = [];
  window.CMS.sortableList = {
    init: function init() {
      var root = arguments.length > 0 && arguments[0] !== undefined ? arguments[0] : document;
      var _iteratorNormalCompletion = true;
      var _didIteratorError = false;
      var _iteratorError = undefined;

      try {
        for (var _iterator = root.querySelectorAll('.sortable')[Symbol.iterator](), _step; !(_iteratorNormalCompletion = (_step = _iterator.next()).done); _iteratorNormalCompletion = true) {
          var sortableRoot = _step.value;
          sortableInstances.push(Sortable.create(sortableRoot, {
            handle: '.dragger',
            draggable: 'li',
            dataIdAttr: DATA_ID_ATTRIBUTE,
            store: sortableStore,
            onStart: function onStart(evt) {
              return evt.from.classList.add('sortable-active');
            },
            onEnd: function onEnd(evt) {
              return evt.from.classList.remove('sortable-active');
            }
          }));
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
    },
    dispose: function dispose() {
      var _iteratorNormalCompletion2 = true;
      var _didIteratorError2 = false;
      var _iteratorError2 = undefined;

      try {
        for (var _iterator2 = sortableInstances[Symbol.iterator](), _step2; !(_iteratorNormalCompletion2 = (_step2 = _iterator2.next()).done); _iteratorNormalCompletion2 = true) {
          var sortable = _step2.value;
          sortable.destroy();
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

      sortableInstances.length = 0;
    }
  };
})();
