window.CMS.pageFragments = () => {
  const toggle = document.querySelector('select#fragments-toggle');
  if (toggle === null) return;
  const url = new URL(toggle.dataset.url, document.location.href);
  toggle.addEventListener('change', () => {
    url.searchParams.set('layout_id', toggle.value);
    fetch(url, {credentials: 'same-origin'}).then((resp) => resp.text()).then((html) => {
      document.querySelector('#form-fragments').outerHTML = html;
      CMS.wysiwyg();
      CMS.timepicker();
      CMS.codemirror();
      CMS.fileLinks();
    });
  });
};
