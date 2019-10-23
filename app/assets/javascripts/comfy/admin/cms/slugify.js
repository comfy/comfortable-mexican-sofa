"use strict";

function _slicedToArray(arr, i) { return _arrayWithHoles(arr) || _iterableToArrayLimit(arr, i) || _nonIterableRest(); }

function _nonIterableRest() { throw new TypeError("Invalid attempt to destructure non-iterable instance"); }

function _iterableToArrayLimit(arr, i) { if (!(Symbol.iterator in Object(arr) || Object.prototype.toString.call(arr) === "[object Arguments]")) { return; } var _arr = []; var _n = true; var _d = false; var _e = undefined; try { for (var _i = arr[Symbol.iterator](), _s; !(_n = (_s = _i.next()).done); _n = true) { _arr.push(_s.value); if (i && _arr.length === i) break; } } catch (err) { _d = true; _e = err; } finally { try { if (!_n && _i["return"] != null) _i["return"](); } finally { if (_d) throw _e; } } return _arr; }

function _arrayWithHoles(arr) { if (Array.isArray(arr)) return arr; }

(function () {
  var SLUGIFY_REPLACEMENTS = [[/[àáâã]/g, 'a'], [/ä/g, 'ae'], [/[èéëê]/g, 'e'], [/[ìíïî]/g, 'i'], [/[òóôõ]/g, 'o'], [/ö/g, 'oe'], [/[ùúû]/g, 'u'], [/ü/g, 'ue'], [/ñ/g, 'n'], [/ç/g, 'c'], [/ß/g, 'ss'], [/[·\/,:;_ ]/g, '-']];

  var slugifyValue = function slugifyValue(value) {
    var slug = value.trim().toLowerCase();
    var _iteratorNormalCompletion = true;
    var _didIteratorError = false;
    var _iteratorError = undefined;

    try {
      for (var _iterator = SLUGIFY_REPLACEMENTS[Symbol.iterator](), _step; !(_iteratorNormalCompletion = (_step = _iterator.next()).done); _iteratorNormalCompletion = true) {
        var _step$value = _slicedToArray(_step.value, 2),
            from = _step$value[0],
            to = _step$value[1];

        slug = slug.replace(from, to);
      } // Remove any other URL incompatible characters and replace multiple dashes with just a single one.

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

    return slug.replace(/[^a-z0-9-]/g, '').replace(/-+/g, '-');
  };

  window.CMS.slugify = function () {
    var input = document.querySelector('input[data-slugify=true]');
    var slugInput = document.querySelector('input[data-slug]');
    if (input === null || slugInput === null) return;
    input.addEventListener('input', function () {
      slugInput.value = slugifyValue(input.value);
    });
  };
})();
