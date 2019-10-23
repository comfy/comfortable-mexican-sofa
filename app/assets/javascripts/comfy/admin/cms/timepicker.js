"use strict";

(function () {
  var flatpickrInstances = [];
  window.CMS.timepicker = {
    init: function init() {
      var root = arguments.length > 0 && arguments[0] !== undefined ? arguments[0] : document;
      var datetimes = root.querySelectorAll('input[type=text][data-cms-datetime]');
      var dates = root.querySelectorAll('input[type=text][data-cms-date]');
      if (datetimes.length === 0 && dates.length === 0) return;
      var locale = CMS.getLocale();
      var _iteratorNormalCompletion = true;
      var _didIteratorError = false;
      var _iteratorError = undefined;

      try {
        for (var _iterator = datetimes[Symbol.iterator](), _step; !(_iteratorNormalCompletion = (_step = _iterator.next()).done); _iteratorNormalCompletion = true) {
          var datetime = _step.value;
          flatpickrInstances.push(flatpickr(datetime, {
            format: 'yyyy-mm-dd hh:ii',
            enableTime: true,
            locale: locale
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

      var _iteratorNormalCompletion2 = true;
      var _didIteratorError2 = false;
      var _iteratorError2 = undefined;

      try {
        for (var _iterator2 = dates[Symbol.iterator](), _step2; !(_iteratorNormalCompletion2 = (_step2 = _iterator2.next()).done); _iteratorNormalCompletion2 = true) {
          var date = _step2.value;
          flatpickrInstances.push(flatpickr(date, {
            format: 'yyyy-mm-dd',
            locale: locale
          }));
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
    },
    dispose: function dispose() {
      var _iteratorNormalCompletion3 = true;
      var _didIteratorError3 = false;
      var _iteratorError3 = undefined;

      try {
        for (var _iterator3 = flatpickrInstances[Symbol.iterator](), _step3; !(_iteratorNormalCompletion3 = (_step3 = _iterator3.next()).done); _iteratorNormalCompletion3 = true) {
          var flatpickrInstance = _step3.value;
          flatpickrInstance.destroy();
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

      flatpickrInstances.length = 0;
    }
  };
})();
