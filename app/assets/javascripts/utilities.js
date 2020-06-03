function getUrl(url, callback) {
  var request = new XMLHttpRequest();

  request.onreadystatechange = function() {
    if (request.readyState == 4 && request.status == 200) {
      callback(request.responseText);
    }
  }

  request.open( "GET", url, true );
  request.send( null );
}


function htmlToElement(html) {
  var template = document.createElement('template');
  html = html.trim(); // Never return a text node of whitespace as the result
  template.innerHTML = html;
  return template.content.firstChild;
}


function generateElement(name, classes) {
  var el = document.createElement(name);
  if (classes) {
    el.classList.add(classes.join(','));
  }
  return el;
}


function show(el) {
  el.classList.remove('hidden');
}


function hide(el) {
  el.classList.add('hidden');
}


function hidden(el) {
  return el.classList.contains('hidden');
}


// Simple utility for merging objects, useful for appending new attributes/methods to $scope
function objectMerge(target, source) {
  for (var key in source) {
    if (source.hasOwnProperty(key)) {
      target[key] = value;
    }
  }
  return target;
}


function queryParamsFromUrl() {
  var paramsRaw = window.location.search.substring(1).split('&');
  var params = {};
  for (var i = 0; i < paramsRaw.length; i++) {
    var param = paramsRaw[i].split('=');
    params[param[0]] = param[1];
  }
  return params;
}


function getProperty(el, property) {
  var style = window.getComputedStyle(el, null);
  return style.getPropertyValue(property);
}


function rootUrl() {
  if (window.location.pathname.match(/^\/findingaids/)) {
    root = '/findingaids/';
  }
  else {
    root = '/';
  }
  return root;
}


function inArray(value, array) {
  return array.indexOf(value) > -1;
}


function executeCallback(fn, data){
  if (typeof fn !== 'undefined') {
    fn(data);
  }
}


function deepLink(element, options) {
  options = options || {};
  var offset = document.querySelector('.stickable').offsetHeight;
  var targetPos = element.getBoundingClientRect().top + window.scrollY;
  targetPos = targetPos - offset;
  window.scrollTo(0, targetPos);
  if (options['highlight']) {
    element.classList.add('highlight');
  }
  return element;
}


function deepLinkToId(targetId, options) {
  options = options || {};
  if (targetId) {
    var target = document.querySelector('#' + targetId);
    deepLink(target, options);
  }
}


function currentTab() {
  var tabOptions = ['summary','contents','terms','access'];
  var path = window.location['pathname'].replace(/^\//,'');
  var path_parts = path.split('/');
  var last_path_segment = path_parts[path_parts.length - 1];
  if (tabOptions.indexOf(last_path_segment) > -1) {
    return last_path_segment;
  }
  else {
    return 'summary';
  }
}


function targetInElement(element, eventTarget) {
  if (element.contains(eventTarget)) {
    return true;
  }
  else {
    return false;
  }
}


// Sort an array of objects on the value corresponding to key
function sortArrayOfObjects(array, key, direction) {
  var sortValues = [];
  var sortedContents = [];

  array.forEach(function(item, index) {
    var compVal = (typeof item[key] == 'string') ? item[key].toLowerCase() : item[key];
    sortValues.push([ index, compVal ]);
  });

  sortValues = sortValues.sort(function(a,b) {
    if (a[1] < b[1]) {
      return -1;
    }
    if (a[1] > b[1]) {
      return 1;
    }
    return 0;
  });

  sortValues.forEach(function(values) {
    var i = values[0];
    sortedContents.push(array[i]);
  });

  if (direction == 'desc') {
    sortedContents = sortedContents.reverse();
  }
  return sortedContents;
}


function removeNode(node) {
  var parent = node.parentNode;
  parent.removeChild(node);
}
