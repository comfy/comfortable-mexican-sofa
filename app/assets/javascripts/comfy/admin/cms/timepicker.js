(() => {
  const flatpickrInstances = [];
  window.CMS.timepicker = {
    init(root = document) {
      const datetimes = root.querySelectorAll('input[type=text][data-cms-datetime]');
      const dates = root.querySelectorAll('input[type=text][data-cms-date]');
      if (datetimes.length === 0 && dates.length === 0) return;
      const locale = CMS.getLocale();
      for (const datetime of datetimes) {
        flatpickrInstances.push(flatpickr(datetime, {
          format: 'yyyy-mm-dd hh:ii',
          enableTime: true,
          locale: locale,
        }));
      }
      for (const date of dates) {
        flatpickrInstances.push(flatpickr(date, {
          format: 'yyyy-mm-dd',
          locale: locale,
        }));
      }
    },
    dispose() {
      for (const flatpickrInstance of flatpickrInstances) {
        flatpickrInstance.destroy();
      }
      flatpickrInstances.length = 0;
    }
  };
})();
