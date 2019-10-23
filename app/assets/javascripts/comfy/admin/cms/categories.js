"use strict";

(function () {
  window.CMS.categories = function () {
    var root = arguments.length > 0 && arguments[0] !== undefined ? arguments[0] : document;
    var widget = root.querySelector('.categories-widget');
    if (widget === null) return;
    var readSection = widget.querySelector('.read');
    var editSection = widget.querySelector('.editable');
    widget.querySelector('.read button.toggle-cat-edit').addEventListener('click', function () {
      readSection.style.display = 'none';
      editSection.style.display = 'block';
    });
    widget.querySelector('.editable button.toggle-cat-edit').addEventListener('click', function () {
      editSection.style.display = 'none';
      readSection.style.display = 'block';
    });
  };
})();
