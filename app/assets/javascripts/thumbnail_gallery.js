class ThumbnailGallery {

  constructor(config) {
    this.#initialize(config);
  }

  #initialize(config) {
    this.thumbnailViewersLoaded = 0;
    this.thumbnailViewers = document.getElementsByClassName('thumbnail-viewer');
    this.totalThumbnailViewers = this.thumbnailViewers.length;

    if (this.totalThumbnailViewers > 0) {
      this.#activateThumbnailViewers();
    }
    else {
      this.#hideVisibilityToggleIfNoViewers();
    }
  }

  #getAlternateElements(viewerId) {
    const elements = [];
    const idsString = viewerId.replace(/#thumbnail-viewer-/,'');
    const doIds = idsString.split('-');

    doIds.forEach(function(id) {
      const linkId = 'digital-object-link-' + id;
      const el = document.getElementById(linkId);

      if (el) {
        elements.push(el);
      }
    });
    return elements;
  }

  #hideAlternateElements(viewerId) {
    const altElements = this.#getAlternateElements(viewerId);

    altElements.forEach(function(el) {
      if (!el.classList.contains('hidden')) {
        el.classList.add('hidden');
      }
    });
  }

  #showAlternateElements(viewerId) {
    const altElements = this.#getAlternateElements(viewerId);

    altElements.forEach(function(el) {
      if (el.classList.contains('hidden')) {
        el.classList.remove('hidden');
      }
    });
  }

  #hideAllViewers() {
    for (let i = 0; i < this.totalThumbnailViewers; i++) {
      let viewer = this.thumbnailViewers[i];
      if (!viewer.classList.contains('hidden')) {
        viewer.classList.add('hidden');
        this.#showAlternateElements(viewer.id);
      }
    }
  }

  #showAllViewers() {
    for (let i = 0; i < this.totalThumbnailViewers; i++) {
      const viewer = this.thumbnailViewers[i];
      if (viewer.classList.contains('hidden')) {
        viewer.classList.remove('hidden');
        this.#hideAlternateElements(viewer.id);
      }
    }
  }

  #getTopVisibleTreeItemId() {
    const stuckHeader = document.querySelectorAll('.stickable.persistent-header.sticky')[0];

    if (!stuckHeader) {
      return null;
    }
    else {
      const headerOffset = stuckHeader.offsetHeight;
      const main = document.querySelectorAll('main')[0];
      const mainOffset = main.offsetTop;
      const scrollPos = window.scrollY;
      const testPos = scrollPos + headerOffset;
      const treeItems = document.querySelectorAll('.tree-item');

      for (let i = 0; i < treeItems.length; i++) {
        const treeItem = treeItems[i];
        const treeItemPos = treeItem.offsetTop + mainOffset;
        const treeItemId = treeItem.id;

        if (treeItemPos >= testPos) {
          return treeItemId || null;
        }
      }
    }
  }

  #scrollToElement(elementId) {
    let scrollPos = 0;

    if (elementId) {
      const main = document.querySelectorAll('main')[0];
      const mainOffset = main.offsetTop;
      const el = document.getElementById(elementId);
      const stuckHeader = document.querySelectorAll('.stickable.persistent-header.sticky')[0];
      const headerOffset = stuckHeader.offsetHeight;
      scrollPos = (el.offsetTop + mainOffset) - headerOffset;
    }

    window.scroll(0, scrollPos);
  }

  #enableThumbnailVisibilityToggle() {
    const _this = this;
    const toggleWrapper = document.getElementsByClassName('thumbnail-visibility-toggle')[0];

    if (toggleWrapper) {
      const toggle = document.createElement("span");
      const toggleShowText = '<i class="far fa-image" aria-hidden="true"></i> Show image thumbnails';
      const toggleHideText = '<i class="far fa-image" aria-hidden="true"></i> Hide image thumbnails';
      toggle.classList.add('link');
      toggle.setAttribute('data-toggle-mode', 'hide');
      toggle.innerHTML = toggleHideText;

      toggle.addEventListener('click', function() {
        const topVisibleElementId = _this.#getTopVisibleTreeItemId();
        const mode = this.getAttribute('data-toggle-mode');

        if (mode == 'hide') {
          _this.#hideAllViewers();
          toggle.innerHTML = toggleShowText;
          toggle.setAttribute('data-toggle-mode', 'show');
        }
        else if (mode == 'show') {
          _this.#showAllViewers();
          toggle.innerHTML = toggleHideText;
          toggle.setAttribute('data-toggle-mode', 'hide');
        }
        
        _this.#scrollToElement(topVisibleElementId);
      });

      toggleWrapper.appendChild(toggle);
    }
  }

  // Remove visibility toggle if all viewres were deleted because there were no images in manifests
  // This function will be passed as callback to ThumbnailViewer on last iteration
  #hideVisibilityToggleIfNoViewers() {
    if (this.thumbnailViewers.length == 0) {
      const toggleWrapper = document.getElementsByClassName('thumbnail-visibility-toggle')[0];
      if (toggleWrapper) {
        hide(toggleWrapper);
      }
    }
  }


  #activateThumbnailViewers() {
    if (this.totalThumbnailViewers > 0) {
      let viewerConfig = {
        thumbnailMaxWidth: 90
      }

      for (let i = 0; i < this.totalThumbnailViewers; i++) {
        const viewerContainer = this.thumbnailViewers[i];
        
        if (viewerContainer) {
          viewerConfig['selector'] = "#" + viewerContainer.id;
          const viewer = new ThumbnailViewer(viewerConfig);
          this.thumbnailViewersLoaded++;
        }
      }

      this.#enableThumbnailVisibilityToggle();
    }
  }
}
