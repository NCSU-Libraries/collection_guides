function thumbnailViewers(callback) {

  var thumbnailViewersLoaded = 0;
  var totalThumbnailViewers;

  function executeCallback(fn, data){
    if (typeof fn !== 'undefined') {
      fn(data);
    }
  }

  function ThumbnailViewer(config) {
    var _this = this;
    this.initialize(config);
  }

  ThumbnailViewer.prototype.initialize = function(config) {
    this.manifestUrl = config.manifestUrl;
    this.selector = config.selector;
    this.callback = config.callback;

    this.thumbnailWidth = config.thumbnailWidth;
    this.thumbnailHeight = config.thumbnailHeight;
    this.thumbnailMaxWidth = config.thumbnailMaxWidth || 90;
    this.thumbnailMaxHeight = config.thumbnailMaxHeight || Math.floor(this.thumbnailMaxWidth * 1.618);
    this.thumbnailWidthVal = this.thumbnailWidth || this.thumbnailMaxWidth;

    if (this.thumbnailHeight) {
      this.thumbnailHeightVal = this.thumbnailHeight;
    }
    else if (this.thumbnailWidth) {
      this.thumbnailHeightVal = this.thumbnailWidth;
    }
    else {
      this.thumbnailHeightVal = this.thumbnailMaxHeight;
    }

    this.thumbnailRotation = this.thumbnailRotation || 0;
    this.thumbnailSpacing = config.thumbnailSpacing || 15;
    this.scrollControlWidth = config.scrollControlWidth || Math.ceil(this.thumbnailWidthVal / 2.75);
    this.viewerElement = document.querySelectorAll(this.selector)[0];

    this.configureViewerWidth();

    this.thumbnailLinkFunction = config.thumbnailLinkFunction;
    this.thumbnailLinkTarget = config.thumbnailLinkTarget || '_blank';

    var regionValues = ['full','square'];

    if (config.thumbnailRegion && (regionValues.indexOf(config.thumbnailRegion) >= 0)) {
      this.thumbnailRegion = config.thumbnailRegion;
    }
    else {
      this.thumbnailRegion = 'full';
    }

    this.showThumbnailsLabel = '<i class="fa fa-picture-o" aria-hidden="true"></i>Show thumbnails';
    this.hideThumbnailsLabel = '<i class="fa fa-picture-o" aria-hidden="true"></i>Hide thumbnails';
    this.viewerElementMinWidth = (this.scrollControlWidth * 2) + (this.thumbnailSpacing * 2) + this.thumbnailWidthVal;
    this.images = [];
  }


  ThumbnailViewer.prototype.configureViewerWidth = function() {
    var viewerStyle = window.getComputedStyle(this.viewerElement);
    this.viewerWidthOverall = parseInt(viewerStyle.width.replace(/[^\d]*/,''));
    this.viewerWidthInner = this.viewerWidthOverall - (this.scrollControlWidth * 2) - this.thumbnailSpacing;
  }


  ThumbnailViewer.prototype.thumbnailUrl = function(image) {
    if (this.thumbnailUrlFunction) {
      return this.thumbnailUrlFunction(image);
    }
    else {
      var serviceId = image['resource']['service']['@id'];
      var region = this.thumbnailRegion;
      var dimensions;
      if (this.thumbnailWidth || this.thumbnailHeight) {
        dimensions = (this.thumbnailWidth || '') + ',' + (this.thumbnailHeight || '');
      }
      else {
        dimensions = '!' + this.thumbnailMaxWidth + ',' + this.thumbnailMaxHeight;
      }
      var rotation = this.thumbnailRotation;
      var urlExtension = '/' + region + '/' +  dimensions + '/' + rotation + '/default.jpg';
      return serviceId + urlExtension;
    }
  }


  ThumbnailViewer.prototype.setManifestUrl = function(url) {
    this.manifestUrl = url;
  }


  ThumbnailViewer.prototype.hideActiveViewers = function() {
    var _this = this;
    var selector = this.selector + '.active';
    var activeViewers = document.querySelectorAll(selector);
    for (var i = 0; i < activeViewers.length; i++) {
      var viewer = activeViewers[i];
      var thumbnailInner = viewer.getElementsByClassName('thumbnail-viewer-inner')[0];
      viewer.classList.remove('active');
      thumbnailInner.classList.add('hidden');
    }
  }


  ThumbnailViewer.prototype.toggleVisibility = function(element) {
    var _this = this;
    var thumbnailInner = this.viewerElement.getElementsByClassName('thumbnail-viewer-inner')[0];
    if (this.viewerElement.classList.contains('active')) {
      this.viewerElement.classList.remove('active');
      thumbnailInner.classList.add('hidden');
      element.innerHTML = this.showThumbnailsLabel;
    }
    else {
      this.viewerElement.classList.add('active');
      thumbnailInner.classList.remove('hidden');
      element.innerHTML = this.hideThumbnailsLabel;
    }
  }


  ThumbnailViewer.prototype.generateVisibilityToggle = function() {
    var _this = this;
    var toggle = document.createElement("span");
    toggle.classList.add('visibility-toggle');
    toggle.innerHTML = this.showThumbnailsLabel;
    toggle.addEventListener('click', function() {
      _this.toggleVisibility(this);
    });
    return toggle;
  }


  ThumbnailViewer.prototype.httpRequest = function(url, callback) {
    var xmlhttp = new XMLHttpRequest();
    xmlhttp.onreadystatechange = function() {
      if (xmlhttp.readyState == XMLHttpRequest.DONE ) {
        if (xmlhttp.status == 200) {
          callback(xmlhttp.responseText);
        }
        else {
          console.log('XMLHttpRequest was unsuccessful');
          console.log(xmlhttp);
        }
      }
    };
    xmlhttp.open("GET", url, true);
    xmlhttp.send();
  }


  ThumbnailViewer.prototype.executeCallback = function(fn, data) {
    executeCallback(fn, data);
  }


  ThumbnailViewer.prototype.testOutput = function(testData) {
    var testDisplayElement = document.querySelectorAll('#test-output')[0];
    if (testDisplayElement) {
      var json = JSON.parse(testData);
      testDisplayElement.innerHTML = '<pre>' + JSON.stringify(json, null, 2) + '</pre>';
    }
  }


  ThumbnailViewer.prototype.getManifests = function(callback1, callback2) {
    this.manifests = [];

    if (this.manifestUrl && !Array.isArray(this.manifestUrl)) {
      this.manifestUrl = [ this.manifestUrl ];
    }

    var manifestCount = this.manifestUrl.length;
    var i = 0;
    var _this = this;

    var getManifest = function() {
      var manifestUrl = _this.manifestUrl[i];

      var requestCallback = function(data) {
        i++;
        var manifest = JSON.parse(data);
        _this.manifests.push(manifest);
        // _this.testOutput(data);
        if (i < manifestCount) {
          getManifest();
        }
        else {
          thumbnailViewersLoaded++;
          console.log(thumbnailViewersLoaded + '/' + totalThumbnailViewers);
          _this.executeCallback(callback1);
          if (thumbnailViewersLoaded == totalThumbnailViewers) {
            _this.executeCallback(callback2);
          }
        }
      }

      _this.httpRequest(manifestUrl, requestCallback);
    }

    getManifest();
  }


  ThumbnailViewer.prototype.generate = function() {
    var _this = this;

    if (!this.viewerElement.classList.contains('thumbnail-viewer')) {
      this.viewerElement.classList.add('thumbnail-viewer');
    }

    this.viewerElement.style.minWidth = _this.viewerElementMinWidth;

    var buildViewer = function() {
      _this.viewerElement.classList.add('hidden');
      // remove old content
      _this.viewerElement.innerHTML = '';
      var element = document.createElement("div");
      element.classList.add('thumbnail-viewer-inner');
      _this.viewerElement.appendChild(element);

      function getFirstSequence(manifest) {
        if (manifest['sequences'] && manifest['sequences'][0]) {
          return manifest['sequences'][0];
        }
      }

      function getFirstCanvas(sequence) {
        if (sequence['canvases'] && sequence['canvases'][0]) {
          return sequence['canvases'][0];
        }
      }

      function getFirstImage(canvas) {
        if (canvas['images'] && canvas['images'][0]) {
          return canvas['images'][0];
        }
      }

      function getThumbnailData(manifest) {
        var data = null;
        var sequence = getFirstSequence(manifest);
        if (sequence) {
          var canvas = getFirstCanvas(sequence);
          if (canvas) {
            var image = getFirstImage(canvas);
            if (image) {
              data = {};
              data['thumbnailSrc'] = _this.thumbnailUrl(image);
              data['thumbnailLinkHref'] = _this.thumbnailLinkFunction(manifest, image);
              data['imageCount'] = sequence['canvases'].length;
              data['title'] = manifest['label'];
            }
          }
        }
        return data;
      }

      function createAnchorElement(href) {
        var aElement = document.createElement("a");
        aElement.setAttribute('href', href);
        aElement.setAttribute('target', _this.thumbnailLinkTarget);
        return aElement;
      }

      var wrapperHeight = 0;

      var loadedImages = 0;


      function enableTooltip(element) {
        var a = element.querySelectorAll('a')[0];
        var tipText = a.getAttribute('title');
        a.removeAttribute('title');
        var titleTip = document.createElement('div');
        titleTip.style.width = '300px';
        titleTip.innerHTML = tipText;
        titleTip.classList.add('title-tip','hidden')
        element.appendChild(titleTip);

        var thumbnailElement = element.parentElement;
        var thumnailViewerInner = thumbnailElement.parentElement;
        var containerBox = thumnailViewerInner.getBoundingClientRect();

        element.addEventListener('mouseover', function(event) {
          var containerWidth = containerBox.width;
          var mouseLeft = (event.clientX + window.scrollX) - containerBox.left;
          var titleTipWidth = parseInt(titleTip.style.width);
          if ((containerWidth - mouseLeft) < titleTipWidth) {
            titleTip.style.right = '5px';
          }
          else {
            titleTip.style.left = '5px';
          }
          titleTip.classList.remove('hidden');
        });
        element.addEventListener('mouseout', function(event) {
          titleTip.classList.add('hidden');
        });
      }


      function generateThumbnailElement(thumbnailData) {
        var thumbnailElement = document.createElement("div");
        var src = thumbnailData['thumbnailSrc'];
        thumbnailElement.classList.add('thumbnail');
        thumbnailElement.style.width = _this.thumbnailWidthVal + 'px';
        thumbnailElement.style.marginRight = _this.thumbnailSpacing + 'px';

        var aElement = createAnchorElement(thumbnailData['thumbnailLinkHref']);

        aElement.setAttribute('title', thumbnailData['title']);

        var imgElement = document.createElement("img");
        imgElement.setAttribute('src', src);

        var textElement = document.createElement("span");
        textElement.classList.add('thumbnail-label');
        // var label = thumbnailData['imageCount'] > 1 ? (thumbnailData['imageCount'] + ' images') : '&nbsp;';
        var label = '1 of ' + thumbnailData['imageCount'];
        textElement.innerHTML = label;

        var image = new Image();
        image.src = src;
        var imgHeight;
        var imgWidth;
        image.onload = function() {
          imgHeight = this.height;
          imgWidth = this.width;
          imgElement.setAttribute('width', imgWidth);
          imgElement.setAttribute('height', imgHeight);
          if (wrapperHeight < imgHeight) {
            wrapperHeight = imgHeight;
          }
          var thumbnailWrapper = document.createElement("div");
          thumbnailWrapper.classList.add('thumbnail-wrapper');
          // aElement.appendChild(imgElement);
          thumbnailWrapper.appendChild(aElement);
          thumbnailWrapper.appendChild(imgElement);
          thumbnailElement.appendChild(thumbnailWrapper);
          thumbnailElement.appendChild(textElement);
          element.appendChild(thumbnailElement);
          loadedImages++;

          enableTooltip(thumbnailWrapper);
        }
      }

      for (var i = 0; i < _this.manifests.length; i++) {
        var manifest = _this.manifests[i];
        var thumbnailData = getThumbnailData(manifest);
        if (thumbnailData) {
          generateThumbnailElement(thumbnailData);
        }
      }

      // One image per manifest
      var setThumbnailWrapperHeight = function() {
        if (loadedImages == _this.manifests.length) {
          var wrappers = element.getElementsByClassName('thumbnail-wrapper');
          for (var i = 0; i < wrappers.length; i++) {
            var wrapper = wrappers[i];
            wrapper.style.height = wrapperHeight + 'px';
          }
        }
        else {
          setTimeout(setThumbnailWrapperHeight, 20);
        }
      }

      setThumbnailWrapperHeight();
      _this.viewerElement.classList.remove('hidden');
    }

    this.getManifests(buildViewer, this.callback);
  }



  function activateThumnailViewers() {

    var thumbnailViewers = document.getElementsByClassName('thumbnail-viewer');

    totalThumbnailViewers = thumbnailViewers.length;

    function hideAllViewers() {
      for (var i = 0; i < totalThumbnailViewers; i++) {
        var viewer = thumbnailViewers[i];
        if (!viewer.classList.contains('hidden')) {
          viewer.classList.add('hidden');
        }
      }
    }

    function showAllViewers() {
      for (var i = 0; i < totalThumbnailViewers; i++) {
        var viewer = thumbnailViewers[i];
        if (viewer.classList.contains('hidden')) {
          viewer.classList.remove('hidden');
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
        var toggleShowText = '<i class="fa fa-picture-o" aria-hidden="true"></i> Show image thumbnails';
        var toggleHideText = '<i class="fa fa-picture-o" aria-hidden="true"></i> Hide image thumbnails';
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

      for (var i = 0; i < thumbnailViewers.length; i++) {
        var viewerContainer = thumbnailViewers[i];
        var id = viewerContainer.id;
        var manifestUrl = viewerContainer.getAttribute('data-manifest-url');

        if (manifestUrl) {
          if (manifestUrl.match(/^http\:/)) {
            manifestUrl = manifestUrl.replace(/^http\:/g,'https:');
          }

          var manifestUrls = manifestUrl.split(' ');

          if (manifestUrls.length > 0) {
            viewerConfig['selector'] = '#' + id;
            viewerConfig['manifestUrl'] = manifestUrl.split(' ');
            viewerConfig['callback'] = callback;
            var viewer = new ThumbnailViewer(viewerConfig);
            viewer.generate();
          }
        }
      }

      enableThumbnailVisibilityToggle();
    }

  }

  activateThumnailViewers();
}
