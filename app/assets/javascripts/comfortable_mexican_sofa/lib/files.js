(function($) {
   window.CMS || (window.CMS = {});

   window.CMS.files = function() {
    var modal = $('.cms-files-modal');

    $('.cms-files-open-modal').on('click', function(e) {
      modal.on('show.bs.modal', function() {
        var iframe = modal.find('iframe'),
            iframeSrc = modal.data('iframe-src');
        if(iframe.attr('src') != iframeSrc) {
          iframe.attr('src', iframeSrc);
        }
      });
      modal.modal({show: true});
      e.preventDefault();
    });

    // Make the files library modal window fill the browsers available height.
    modal.on('show.bs.modal', function (e) {
      $(e.target).find('.modal-content').css('height', ($(window).height()-60) + 'px');
    });

    $(window).on('resize', function(){
      modal.find('.modal-content').css('height', ($(window).height()-60) + 'px');
    });

    // When clicking a file path in the file list select it to make
    // it easy to copy&paste.
    $(document).on('click', '.cms-uploader-filelist input[type=text]', function() {
      $(this).select();
    });

   };
})(jQuery);
