ContentsList.prototype.thumbnailViewers = function(callback) {

  var thumbnailViewersLoaded = 0;
  var totalThumbnailViewers;


  function activateThumbnailViewers() {

    var thumbnailViewers = document.getElementsByClassName('thumbnail-viewer');

    totalThumbnailViewers = thumbnailViewers.length;


    function getAlternateElements(viewerId) {
      var elements = [];
      var idsString = viewerId.replace(/#thumbnail-viewer-/,'');
      var doIds = idsString.split('-');
      doIds.forEach(function(id) {
        var linkId = 'digital-object-link-' + id;
        el = document.querySelector('#' + linkId);
        if (el) {
          elements.push(el);
        }
      });
      return elements;
    }


    function hideAlternateElements(viewerId) {
      var altElements = getAlternateElements(viewerId);
      altElements.forEach(function(el) {
        if (!el.classList.contains('hidden')) {
          el.classList.add('hidden');
        }
      });
    }


    function showAlternateElements(viewerId) {
      var altElements = getAlternateElements(viewerId);
      altElements.forEach(function(el) {
        if (el.classList.contains('hidden')) {
          el.classList.remove('hidden');
        }
      });
    }


    function hideAllViewers() {
      for (var i = 0; i < totalThumbnailViewers; i++) {
        var viewer = thumbnailViewers[i];
        if (!viewer.classList.contains('hidden')) {
          viewer.classList.add('hidden');
          showAlternateElements(viewer.id);
        }
      }
    }

    function showAllViewers() {
      for (var i = 0; i < totalThumbnailViewers; i++) {
        var viewer = thumbnailViewers[i];
        if (viewer.classList.contains('hidden')) {
          viewer.classList.remove('hidden');
          hideAlternateElements(viewer.id);
        }
      }
    }

    function getTopVisibleTreeItemId() {
      var stuckHeader = document.querySelectorAll('.stickable.persistent-header.sticky')[0];
      if (!stuckHeader) {
        return null;
      }
      else {
        var headerOffset = stuckHeader.offsetHeight;
        var main = document.querySelectorAll('main')[0];
        var mainOffset = main.offsetTop;
        var scrollPos = window.scrollY;
        var testPos = scrollPos + headerOffset;
        var treeItems = document.querySelectorAll('.tree-item');
        for (var i = 0; i < treeItems.length; i++) {
          var treeItem = treeItems[i];
          var treeItemPos = treeItem.offsetTop + mainOffset;
          var treeItemId = treeItem.id;
          if (treeItemPos >= testPos) {
            if (treeItemId) {
              return treeItemId;
            }
            else {
              return null;
            }
          }
        }
      }
    }

    function scrollToElement(elementId) {
      var scrollPos = 0;
      if (elementId) {
        var main = document.querySelectorAll('main')[0];
        var mainOffset = main.offsetTop;
        var el = document.getElementById(elementId);
        var stuckHeader = document.querySelectorAll('.stickable.persistent-header.sticky')[0];
        var headerOffset = stuckHeader.offsetHeight;
        scrollPos = (el.offsetTop + mainOffset) - headerOffset;
      }
      window.scroll(0, scrollPos);
    }


    function enableThumbnailVisibilityToggle() {
      var toggleWrapper = document.getElementsByClassName('thumbnail-visibility-toggle')[0];

      if (toggleWrapper) {
        var toggle = document.createElement("span");
        var toggleShowText = '<i class="far fa-image" aria-hidden="true"></i> Show image thumbnails';
        var toggleHideText = '<i class="far fa-image" aria-hidden="true"></i> Hide image thumbnails';
        toggle.classList.add('link');
        toggle.setAttribute('data-toggle-mode', 'hide');
        toggle.innerHTML = toggleHideText;

        toggle.addEventListener('click', function() {
          var topVisibleElementId = getTopVisibleTreeItemId();
          var mode = this.getAttribute('data-toggle-mode');
          if (mode == 'hide') {
            hideAllViewers();
            toggle.innerHTML = toggleShowText;
            toggle.setAttribute('data-toggle-mode', 'show');
          }
          else if (mode == 'show') {
            showAllViewers();
            toggle.innerHTML = toggleHideText;
            toggle.setAttribute('data-toggle-mode', 'hide');
          }
          executeCallback(callback);
          scrollToElement(topVisibleElementId);
        });

        toggleWrapper.appendChild(toggle);
      }
    }


    // Remove visibility toggle if all viewres were deleted because there were no images in manifests
    // This function will be passed as callback to ThumbnailViewer on last iteration
    function hideVisibilityToggleIfNoViewers() {
      thumbnailViewers = document.getElementsByClassName('thumbnail-viewer');
      if (thumbnailViewers.length == 0) {
        var toggleWrapper = document.getElementsByClassName('thumbnail-visibility-toggle')[0];
        hide(toggleWrapper);
      }
    }


    if (totalThumbnailViewers > 0) {
      var thumbnailLinkFunction = function(manifest, image, index) {
        var id = manifest['@id'];
        var link = id.replace(/\/manifest\/?(\.jso?n)?$/,'');
        // link = link + '#?cv=' + index;
        return link;
      }

      var viewerConfig = {
        thumbnailLinkFunction: thumbnailLinkFunction,
        thumbnailMaxWidth: 90
      }

      for (var i = 0; i < totalThumbnailViewers; i++) {
        var viewerContainer = thumbnailViewers[i];
        var id = viewerContainer.id;
        var manifestUrl = viewerContainer.getAttribute('data-manifest-url');

        if (manifestUrl) {
          var manifestUrls = manifestUrl.split(' ');

          if (manifestUrls.length > 0) {
            var viewerId = '#' + id;
            viewerConfig['selector'] = viewerId;
            viewerConfig['manifestUrl'] = manifestUrl.split(' ');

            if (i < totalThumbnailViewers -1) {
              viewerConfig['callbacks'] = [callback];
            }
            else {
              viewerConfig['callbacks'] = [hideVisibilityToggleIfNoViewers, callback];
            }

            var viewer = new ThumbnailViewer(viewerConfig);
            hideAlternateElements(viewerId);
            viewer.generate();
            thumbnailViewersLoaded++;
            // console.log(thumbnailViewersLoaded + '/' + totalThumbnailViewers);
          }
        }
      }

      enableThumbnailVisibilityToggle();
    }

  }

  activateThumbnailViewers();
}
