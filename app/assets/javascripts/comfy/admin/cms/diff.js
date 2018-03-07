(() => {
  window.CMS.diff = () => {
    jQuery('.revision').prettyTextDiff({
      cleanup: true,
      originalContainer: '.original',
      changedContainer: '.current',
      diffContainer: '.diff .content',
    });
  }
})();
