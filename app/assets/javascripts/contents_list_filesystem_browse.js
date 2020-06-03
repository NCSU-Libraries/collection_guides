ContentsList.prototype.enableFilesystemBrowseLinks = function() {
  var filesystemBrowseLinks = document.querySelectorAll('.filesystem-browse-link');

  for (var i = 0; i < filesystemBrowseLinks.length; i++) {
    var link = filesystemBrowseLinks[i];

    link.addEventListener('click', function(e) {
      var volumeId = this.getAttribute('data-volume-id');
      var modal = new Modal();
      var browserConfig = {
        volumeId: volumeId,
        rootElementSelector: '#modal'
      };
      modal.open({
        content: '<div id="filesystem-browser"></div>',
        callback: function() {
          new FilesystemBrowser(browserConfig);
        }
      });
      e.stopPropagation();
      e.preventDefault();
      return false;
    });
  }
}
