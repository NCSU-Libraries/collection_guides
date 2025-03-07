class ThumbnailViewer {
  
  constructor(config) {
    this.#initialize(config);
  }

  #initialize(config) {
    this.selector = config.selector;
    this.viewerElement = document.querySelector(this.selector);

    if (this.viewerElement) {
      this.#setAttributes(config);
      if (this.templates.length > 0) {
        this.generate();
      }
    }
  }

  #setAttributes(config) {
    this.selector = config.selector;
    this.templates = this.viewerElement.querySelectorAll('template.image-data');
    this.callbacks = config.callbacks;
    this.thumbnailWidth = config.thumbnailWidth;
    this.thumbnailHeight = config.thumbnailHeight;
    this.thumbnailMaxWidth = config.thumbnailMaxWidth || 90;
    this.thumbnailMaxHeight = config.thumbnailMaxHeight || Math.floor(this.thumbnailMaxWidth * 1.618);
    this.thumbnailWidthVal = this.thumbnailWidth || this.thumbnailMaxWidth;
    this.thumbnailRotation = config.thumbnailRotation || 0;
    this.thumbnailSpacing = config.thumbnailSpacing || 15;
    this.scrollControlWidth = config.scrollControlWidth || Math.ceil(this.thumbnailWidthVal / 2.75);
    this.thumbnailLinkFunction = config.thumbnailLinkFunction;
    this.thumbnailLinkTarget = config.thumbnailLinkTarget || '_blank';
    this.images = [];
    this.showThumbnailsLabel = '<i class="fa fa-picture-o" aria-hidden="true"></i>Show thumbnails';
    this.hideThumbnailsLabel = '<i class="fa fa-picture-o" aria-hidden="true"></i>Hide thumbnails';
    const regionValues = ['full','square'];
  
    if (config.thumbnailRegion && (regionValues.indexOf(config.thumbnailRegion) >= 0)) {
      this.thumbnailRegion = config.thumbnailRegion;
    }
    else {
      this.thumbnailRegion = 'full';
    }

    this.#setThumbnailHeightVal();
    this.#setDigitalObjectIds();
    this.#configureViewerWidth();
  }

  #setThumbnailHeightVal() {
    if (this.thumbnailHeight) {
      this.thumbnailHeightVal = this.thumbnailHeight;
    }
    else if (this.thumbnailWidth) {
      this.thumbnailHeightVal = this.thumbnailWidth;
    }
    else {
      this.thumbnailHeightVal = this.thumbnailMaxHeight;
    }
  }

  #setDigitalObjectIds() {
    const idsString = this.selector.replace(/#thumbnail-viewer-/,'');
    this.digitalObjectIds = idsString.split('-');
  }

  #configureViewerWidth() {
    const viewerStyle = window.getComputedStyle(this.viewerElement);
    this.viewerWidthOverall = parseInt(viewerStyle.width.replace(/[^\d]*/,''));
    this.viewerWidthInner = this.viewerWidthOverall - (this.scrollControlWidth * 2) - this.thumbnailSpacing;
    this.viewerElementMinWidth = (this.scrollControlWidth * 2) + (this.thumbnailSpacing * 2) + this.thumbnailWidthVal;
  }

  #showAlternateContent(digitalObjectId) {
    const linkId = 'digital-object-link-' + digitalObjectId;
    const el = document.querySelector('#' + linkId);
    if (el) {
      show(el);
    }
  }

  #thumbnailUrl(thumbnailBaseUrl) {
    const region = this.thumbnailRegion;
    let dimensions = null;

    if (this.thumbnailWidth || this.thumbnailHeight) {
      dimensions = (this.thumbnailWidth || '') + ',' + (this.thumbnailHeight || '');
    }
    else {
      dimensions = '!' + this.thumbnailMaxWidth + ',' + this.thumbnailMaxHeight;
    }

    const rotation = this.thumbnailRotation;
    const urlExtension = '/' + region + '/' +  dimensions + '/' + rotation + '/default.jpg';
    return thumbnailBaseUrl + urlExtension;
  }

  executeCallback(fn, data) {
    executeCallback(fn, data);
  }

  generate() {
    const _this = this;
    let totalResources = 0;
    let wrapperHeight = 0;
    let loadedImages = 0;
    const element = document.createElement("div");

    if (!this.viewerElement.classList.contains('thumbnail-viewer')) {
      this.viewerElement.classList.add('thumbnail-viewer');
    }
  
    this.viewerElement.style.minWidth = this.viewerElementMinWidth + 'px';
    this.viewerElement.classList.add('hidden');
    element.classList.add('thumbnail-viewer-inner');
    this.viewerElement.appendChild(element);

    function removeTemplates() {
      for (const template of _this.templates) {
        template.remove();
      }
    }

    function generateThumbnailElement(index) {
      const thumbnailElement = document.createElement("div");
      thumbnailElement.classList.add('thumbnail-' + index);
      return thumbnailElement;
    }

    function createAnchorElement(href) {
      const linkText = document.createElement("span");
      const aElement = document.createElement("a");
      linkText.classList.add('sr-only');
      linkText.innerHTML = "View larger image and details";
      aElement.setAttribute('href', href);
      aElement.setAttribute('target', _this.thumbnailLinkTarget);
      aElement.appendChild(linkText);
      return aElement;
    }

    function enableTooltip(element) {
      const a = element.querySelectorAll('a')[0];
      const tipText = a.getAttribute('title');
      const titleTip = document.createElement('div');
      const thumbnailElement = element.parentElement;
      const thumbnailViewerInner = thumbnailElement.parentElement;
      const containerBox = thumbnailViewerInner.getBoundingClientRect();
      a.removeAttribute('title');
      titleTip.style.width = '300px';
      titleTip.innerHTML = tipText;
      titleTip.classList.add('title-tip','hidden');
      element.appendChild(titleTip);
      
      element.addEventListener('mouseover', function(event) {
        const containerWidth = thumbnailViewerInner.offsetWidth;
        const mouseLeft = (event.clientX + window.scrollX) - containerBox.left;
        const titleTipWidth = parseInt(titleTip.style.width);
    
        if ((containerWidth - mouseLeft) < titleTipWidth) {
          titleTip.style.right = '0';
        }
        else {
          titleTip.style.left = '0';
        }
        titleTip.classList.remove('hidden');
      });
      element.addEventListener('mouseout', function(event) {
        titleTip.classList.add('hidden');
      });
    }

    function loadThumbnailElementContent(thumbnailElement, thumbnailData) {
      const src = thumbnailData['thumbnailSrc'];
      const aElement = createAnchorElement(thumbnailData['thumbnailLinkHref']);
      const imgElement = document.createElement("img");
      const alt = thumbnailData['title'] ? thumbnailData['title'].replace(/"/gi,'') : 'thumbnail image';
      const textElement = document.createElement("div");
      const labelSingle = "1 image";
      const labelMulti = '1 of ' + thumbnailData['imageCount'] + ' images';
      const label = (thumbnailData['imageCount'] > 1) ? labelMulti : '&nbsp;';
      const image = new Image();
      let imgHeight = 0;
      let imgWidth = 0;

      thumbnailElement.classList.add('thumbnail');
      thumbnailElement.style.width = _this.thumbnailWidthVal + 'px';
      thumbnailElement.style.marginRight = _this.thumbnailSpacing + 'px';

      aElement.setAttribute('title', thumbnailData['title']);
      imgElement.setAttribute('src', src);
      imgElement.setAttribute('alt', alt);
      textElement.classList.add('thumbnail-label');
      textElement.innerHTML = label;
      image.src = src;

      image.onload = function() {
        imgHeight = this.height;
        imgWidth = this.width;
        imgElement.setAttribute('width', imgWidth);
        imgElement.setAttribute('height', imgHeight);

        if (wrapperHeight < imgHeight) {
          wrapperHeight = imgHeight;
        }
        
        const thumbnailWrapper = document.createElement("div");
        thumbnailWrapper.classList.add('thumbnail-wrapper');
        // aElement.appendChild(imgElement);
        thumbnailWrapper.appendChild(aElement);
        thumbnailWrapper.appendChild(imgElement);
        thumbnailElement.appendChild(thumbnailWrapper);
        thumbnailElement.appendChild(textElement);
        // element.appendChild(thumbnailElement);
        loadedImages++;
        // enableTooltip(thumbnailWrapper);
        enableTooltip(thumbnailElement);
      }
    }

    function buildViewer() {
      for (let i = 0; i < _this.templates.length; i++) {
        let template = _this.templates[i];
        const imageData = JSON.parse(template.innerHTML);
  
        if (imageData) {
          imageData['thumbnailSrc'] = _this.#thumbnailUrl(imageData['thumbnailBaseUrl']);
          const thumbnailElement = generateThumbnailElement(i);
          element.appendChild(thumbnailElement);
          loadThumbnailElementContent(thumbnailElement, imageData);
          totalResources++;
        }
        else {
          const digitalObjectId = _this.digitalObjectIds[i];
          _this.#showAlternateContent(digitalObjectId);
        }
      }

      const setThumbnailWrapperHeight = function() {
        if (loadedImages == _this.templates.length) {
          const wrappers = element.getElementsByClassName('thumbnail-wrapper');
          for (let i = 0; i < wrappers.length; i++) {
            const wrapper = wrappers[i];
            wrapper.style.height = wrapperHeight + 'px';
          }
        }
        else {
          setTimeout(setThumbnailWrapperHeight, 20);
        }
      }
  
      setThumbnailWrapperHeight();
      _this.viewerElement.classList.remove('hidden');
      _this.executeCallbacks();
    }

    buildViewer();
    removeTemplates();
  }


  executeCallbacks() {
    if (this.callbacks && Array.isArray(this.callbacks)) {
      this.callbacks.forEach(function(fn) {
        executeCallback(fn);
      });
    }
  }

}
