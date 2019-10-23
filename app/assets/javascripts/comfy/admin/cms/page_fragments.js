"use strict";

window.CMS.pageFragments = function () {
  var toggle = document.querySelector('select#fragments-toggle');
  if (toggle === null) return;
  var url = new URL(toggle.dataset.url, document.location.href);
  toggle.addEventListener('change', function () {
    url.searchParams.set('layout_id', toggle.value);
    fetch(url, {
      credentials: 'same-origin'
    }).then(function (resp) {
      return resp.text();
    }).then(function (html) {
      var container = document.querySelector('#form-fragments-container');
      container.innerHTML = html; // TODO: Only dispose of the widgets that were within the fragment.

      CMS.wysiwyg.dispose();
      CMS.timepicker.dispose();
      CMS.codemirror.dispose();
      CMS.fileLinks(container); // TODO: Container should also be passed here once the TODO above is addressed.

      CMS.wysiwyg.init();
      CMS.timepicker.init();
      CMS.codemirror.init();
    });
  });
};
