window.CMS.upload_queue = (root = document) => {
  const el = root.querySelector('#cms-uploader');
  if (el === null) return;
  window.CMS.uploader(el, {
    url: el.dataset.cmsUploaderUrl,
    multipart_params: {
      [el.dataset.cmsUploaderTokenName]: el.dataset.cmsUploaderTokenValue,
      [el.dataset.cmsUploaderSessionName]: el.dataset.cmsUploaderSessionValue
    }
  });
};
