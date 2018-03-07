(() => {
  if (!window.CMS) window.CMS = {};
  const CMS = window.CMS;

  // TODO(glebm): Use the battle-tested universal onPageLoad code and enable Turbolinks+async in the demo app.
  // See: https://gist.github.com/glebm/2496daf445877055447a6fac46509d9a
  const isTurbolinks = 'Turbolinks' in window && window.Turbolinks.supported;
  if (isTurbolinks) {
    document.addEventListener('turbolinks:load', () => {
      window.CMS.init();
    });
    document.addEventListener('turbolinks:before-cache', () => {
      window.CMS.dispose();
    });
  } else {
    document.addEventListener('DOMContentLoaded', () => {
      window.CMS.init();
    });
  }

  CMS.init = () => {
    CMS.current_path = window.location.pathname;
    CMS.slugify();
    CMS.codemirror.init();
    CMS.wysiwyg.init();
    CMS.sortableList.init();
    CMS.timepicker.init();
    CMS.pageFragments();
    CMS.categories();
    CMS.files.init();
    CMS.fileLinks();
    CMS.fileUpload.init();
    CMS.diff();
  };

  CMS.dispose = () => {
    CMS.codemirror.dispose();
    CMS.wysiwyg.dispose();
    CMS.files.dispose();
    CMS.fileUpload.dispose();
    CMS.sortableList.dispose();
    CMS.timepicker.dispose();
  };

  CMS.getLocale = () => document.querySelector('meta[name="cms-locale"]').content;
})();
