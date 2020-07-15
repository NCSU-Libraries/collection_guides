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
    var containerWidth = thumnailViewerInner.offsetWidth;
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


function ThumbnailViewer(config) {
  this.initialize(config);
}

ThumbnailViewer.prototype.initialize = function(config) {
  this.manifestUrl = config.manifestUrl;
  this.selector = config.selector;
  this.callbacks = config.callbacks;

  this.getDigitalObjectIds();

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
  this.viewerElement = document.querySelector(this.selector);

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


ThumbnailViewer.prototype.getDigitalObjectIds = function() {
  var idsString = this.selector.replace(/#thumbnail-viewer-/,'');
  this.digitalObjectIds = idsString.split('-');
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



// This commented-out functionality was moved to contents_list_thumbnails.js

// ThumbnailViewer.prototype.hideActiveViewers = function() {
//   var _this = this;
//   var selector = this.selector + '.active';
//   var activeViewers = document.querySelectorAll(selector);
//   for (var i = 0; i < activeViewers.length; i++) {
//     var viewer = activeViewers[i];
//     var thumbnailInner = viewer.getElementsByClassName('thumbnail-viewer-inner')[0];
//     viewer.classList.remove('active');
//     thumbnailInner.classList.add('hidden');
//   }
// }


// ThumbnailViewer.prototype.toggleVisibility = function(element) {
//   var _this = this;
//   var thumbnailInner = this.viewerElement.getElementsByClassName('thumbnail-viewer-inner')[0];
//   if (this.viewerElement.classList.contains('active')) {
//     this.viewerElement.classList.remove('active');
//     thumbnailInner.classList.add('hidden');
//     element.innerHTML = this.showThumbnailsLabel;
//   }
//   else {
//     this.viewerElement.classList.add('active');
//     thumbnailInner.classList.remove('hidden');
//     element.innerHTML = this.hideThumbnailsLabel;
//   }
// }


// ThumbnailViewer.prototype.generateVisibilityToggle = function() {
//   var _this = this;
//   var toggle = document.createElement("span");
//   toggle.classList.add('visibility-toggle');
//   toggle.innerHTML = this.showThumbnailsLabel;
//   toggle.addEventListener('click', function() {
//     _this.toggleVisibility(this);
//   });
//   return toggle;
// }



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

  xmlhttp.addEventListener('error', function() { console.log("ERROR!") });
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


ThumbnailViewer.prototype.getManifests = function(callback) {
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

      console.log(manifestUrl);

      i++;
      var manifest = JSON.parse(data);

      // _this.manifests.push(manifest);
      _this.manifests[i] = manifest;

      if (i < manifestCount) {
        getManifest();
      }
      else {
        _this.thumbnailViewersLoaded++;
        _this.manifests = _this.manifests.filter(x => x);
        _this.executeCallback(callback);
      }
    }

    _this.httpRequest(manifestUrl, requestCallback);
  }

  getManifest();
}


ThumbnailViewer.prototype.getThumbnailData = function(manifest) {
  var data = null;
  var sequence = getFirstSequence(manifest);
  if (sequence) {
    var canvas = getFirstCanvas(sequence);
    if (canvas) {
      var image = getFirstImage(canvas);
      if (image) {
        data = {};
        data['thumbnailSrc'] = this.thumbnailUrl(image);
        data['thumbnailLinkHref'] = this.thumbnailLinkFunction(manifest, image);
        data['imageCount'] = sequence['canvases'].length;
        data['title'] = manifest['label'];
      }
    }
  }
  return data;
}


ThumbnailViewer.prototype.createAnchorElement = function(href) {
  var linkText = document.createElement("span");
  linkText.classList.add('sr-only');
  linkText.innerHTML = "View larger image and details"
  var aElement = document.createElement("a");
  aElement.setAttribute('href', href);
  aElement.setAttribute('target', this.thumbnailLinkTarget);
  aElement.appendChild(linkText);
  return aElement;
}


ThumbnailViewer.prototype.showAlternateContent = function(digitalObjectId) {
  var linkId = 'digital-object-link-' + digitalObjectId;
  el = document.querySelector('#' + linkId);
  show(el);
}


ThumbnailViewer.prototype.executeCallbacks = function() {
  if (this.callbacks && Array.isArray(this.callbacks)) {
    this.callbacks.forEach(function(fn) {
      executeCallback(fn);
    });
  }
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

    var wrapperHeight = 0;

    var loadedImages = 0;


    function generateThumbnailElement(index) {
      var thumbnailElement = document.createElement("div");
      thumbnailElement.classList.add('thumbnail-' + index);
      element.appendChild(thumbnailElement);
      return thumbnailElement;
    }


    function loadThumbnailElementContent(thumbnailElement, thumbnailData) {
      // var thumbnailElement = document.createElement("div");
      var src = thumbnailData['thumbnailSrc'];
      thumbnailElement.classList.add('thumbnail');
      thumbnailElement.style.width = _this.thumbnailWidthVal + 'px';
      thumbnailElement.style.marginRight = _this.thumbnailSpacing + 'px';

      var aElement = _this.createAnchorElement(thumbnailData['thumbnailLinkHref']);

      aElement.setAttribute('title', thumbnailData['title']);

      var imgElement = document.createElement("img");
      imgElement.setAttribute('src', src);
      var alt = thumbnailData['title'] ? thumbnailData['title'].replace(/"/,"'") : 'thumbnail image';
      imgElement.setAttribute('alt', alt);

      var textElement = document.createElement("div");
      textElement.classList.add('thumbnail-label');

      var labelSingle = "1 image";
      var labelMulti = '1 of ' + thumbnailData['imageCount'] + ' images';
      var label = (thumbnailData['imageCount'] > 1) ? labelMulti : '&nbsp;';

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
        // element.appendChild(thumbnailElement);
        loadedImages++;

        enableTooltip(thumbnailWrapper);
      }
    }


    var totalResources = 0;

    for (var i = 0; i < _this.manifests.length; i++) {
      var manifest = _this.manifests[i];

      var thumbnailElement = generateThumbnailElement(i);
      var thumbnailData = _this.getThumbnailData(manifest);
      if (thumbnailData) {
        loadThumbnailElementContent(thumbnailElement, thumbnailData);
        totalResources++;
      }
      else {
        var digitalObjectId = _this.digitalObjectIds[i];
        _this.showAlternateContent(digitalObjectId);
        thumbnailElement.remove();
      }
    }

    // console.log(totalResources);

    if (totalResources == 0) {
      var e = _this.viewerElement;
      e.parentNode.removeChild(e);
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

    _this.executeCallbacks();
  }

  this.getManifests(buildViewer);
}
