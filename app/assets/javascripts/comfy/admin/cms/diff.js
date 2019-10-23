"use strict";

(function () {
  window.CMS.diff = function () {
    jQuery('.revision').prettyTextDiff({
      cleanup: true,
      originalContainer: '.original',
      changedContainer: '.current',
      diffContainer: '.diff .content'
    });
  };
})();
