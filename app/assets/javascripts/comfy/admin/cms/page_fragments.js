window.CMS.pageFragments = () => {
  const toggle = document.querySelector('select#fragments-toggle');
  if (toggle === null) return;
  const url = new URL(toggle.dataset.url, document.location.href);
  toggle.addEventListener('change', () => {
    url.searchParams.set('layout_id', toggle.value);
    fetch(url, {credentials: 'same-origin'}).then((resp) => resp.text()).then((html) => {
      document.querySelector('#form-fragments').outerHTML = html;
      // TODO: Only dispose of the widgets that were within the fragment.
      CMS.wysiwyg.dispose();
      CMS.timepicker.dispose();
      CMS.codemirror.dispose();

      const root = document.querySelector('#form-fragments');
      CMS.fileLinks(root);
      // TODO: Root should also be passed here once the TODO above is addressed.
      CMS.wysiwyg.init();
      CMS.timepicker.init();
      CMS.codemirror.init();
    });
  });
};
