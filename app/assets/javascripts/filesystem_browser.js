function FilesystemBrowser(config) {
  var _this = this;
  this.initialize(config);
  console.log(config);
}


FilesystemBrowser.prototype.initialize = function(config) {
  this.rootUrl = config.rootUrl;
  this.volume = {};
  this.directoryPath = [];
  this.currentDirectory;
  this.currentDirectoryContents;
  this.currentDirectoryContentsFiltered;
  this.filters = {
    'unallocated': false,
    'hidden': false
  };
  this.sortKey = 'name';
  this.sortDirection = 'asc';
  this.selector = config.selector || '#filesystem-browser';
  this.wrapper = document.querySelector(this.selector);
  this.wrapperParent = this.wrapper.parentNode;
  this.getVolume(config.volumeId);
  this.fileObjectMenuActive = false;
  this.body = document.querySelector('body');
  this.rootElementSelector = config.rootElementSelector || 'body';
  this.rootElement = document.querySelector(this.rootElementSelector);
  var loading = document.createElement('div');
  loading.classList.add('loading');
  this.loading = loading;
  this.rootElement.appendChild(this.loading);
}


// Filters based on boolean values only
FilesystemBrowser.prototype.filterCurrentDirectoryContents = function() {
  this.currentDirectoryContentsFiltered = [];
  var _this = this;
  this.currentDirectoryContents.forEach(function(item, index) {
    var include = true;
    for (var key in _this.filters) {
      if (_this.filters.hasOwnProperty(key)) {
        if (!_this.filters[key] && item[key]) {
          include = false;
          break;
        }
      }
    }
    if (include) {
      _this.currentDirectoryContentsFiltered.push(item);
    }
  });
  this.applySort();
}


FilesystemBrowser.prototype.configureStickyHeader = function() {
  var _this = this;
  var header = this.header;
  var contentWrapper = this.wrapperParent;
  var contentWrapperStyle = window.getComputedStyle(contentWrapper);
  var contentWrapperDefaultPadding = contentWrapperStyle.getPropertyValue('padding-top');
  var stickyHeight = header.offsetHeight;
  var offset = stickyHeight;
  var contentWrapperDefaultHeight = contentWrapper.offsetHeight;
  contentWrapper.style.height = (contentWrapperDefaultHeight - offset) + 'px';
  contentWrapper.style.marginTop = offset + 'px';
}


FilesystemBrowser.prototype.getVolume = function(volumeId) {
  var _this = this;
  var root = "<%= ENV['filesystem_browser_api_url'] %>".replace(/\/$/,'');
  var url = root + '/volumes/' + volumeId + '.json';
  var callback = function(data) {
    _this.loading.style.display = 'none';
    _this.volume = JSON.parse(data);
    _this.directoryPath = [ { 'name': 'root' } ];
    _this.setCurrentDirectory(_this.volume.root);
    _this.generate();
    _this.configureStickyHeader();
  }
  getUrl(url,callback);
}


FilesystemBrowser.prototype.getDirectory = function(directoryId) {
  var _this = this;
  var root = "<%= ENV['filesystem_browser_api_url'] %>".replace(/\/$/,'');
  var url = root + '/directories/' + directoryId + '.json';

  var callback = function(data) {
    var dir = JSON.parse(data);
    _this.setCurrentDirectory(dir);
    _this.updateTableBody();
    _this.updateFilters();
  }
  getUrl(url, callback);
}


FilesystemBrowser.prototype.setCurrentDirectory = function(dir) {
  this.currentDirectory = dir;
  this.currentDirectoryContents = dir['children'];
  this.filterCurrentDirectoryContents();
  this.applySort();
}


FilesystemBrowser.prototype.currentDirectoryContainsHidden = function() {
  var containsHidden = null;
  for (var i = 0; i < this.currentDirectoryContents.length; i++) {
    var record = this.currentDirectoryContents[i];
    if (record.hidden) {
      containsHidden = true;
      break;
    }
  }
  return containsHidden;
}


FilesystemBrowser.prototype.currentDirectoryContainsDeleted = function() {
  var containsDeleted = null;
  for (var i = 0; i < this.currentDirectoryContents.length; i++) {
    var record = this.currentDirectoryContents[i];
    if (record.unallocated) {
      containsDeleted = true;
      break;
    }
  }
  return containsDeleted;
}


FilesystemBrowser.prototype.disableHiddenFileFilterControl = function() {
  if (!this.hiddenFileFilterControl.classList.contains('disabled')) {
    this.hiddenFileFilterControl.classList.add('disabled')
  }
}


FilesystemBrowser.prototype.enableHiddenFileFilterControl = function() {
  if (this.hiddenFileFilterControl.classList.contains('disabled')) {
    this.hiddenFileFilterControl.classList.remove('disabled')
  }
}


FilesystemBrowser.prototype.disableDeletedFileFilterControl = function() {
  if (!this.deletedFileFilterControl.classList.contains('disabled')) {
    this.deletedFileFilterControl.classList.add('disabled')
  }
}


FilesystemBrowser.prototype.enableDeletedFileFilterControl = function() {
  if (this.deletedFileFilterControl.classList.contains('disabled')) {
    this.deletedFileFilterControl.classList.remove('disabled')
  }
}


FilesystemBrowser.prototype.updateFilters = function() {

  var containsDeleted = this.currentDirectoryContainsDeleted();
  if (containsDeleted) {
    this.enableDeletedFileFilterControl();
  }
  else {
    this.disableDeletedFileFilterControl();
  }

  var containsHidden = this.currentDirectoryContainsHidden();
  if (containsHidden) {
    this.enableHiddenFileFilterControl();
  }
  else {
    this.disableHiddenFileFilterControl();
  }
}


FilesystemBrowser.prototype.generate = function() {
  var _this = this;
  var header = this.generateHeader();
  // this.wrapperParent.appendChild(header);
  this.wrapperParent.appendChild(header);
  this.header = header;

  var table = this.generateTable();
  this.table = table;

  this.updateTableBody();
  this.updateDirectoryNav();
  this.updateFilters();
  this.wrapper.appendChild(table);

  var fileActionsWrapper = document.createElement('div');
  fileActionsWrapper.classList.add('file-actions-wrapper','hidden');
  this.fileActionsWrapper = fileActionsWrapper;
  this.wrapper.appendChild(fileActionsWrapper);
}


FilesystemBrowser.prototype.generateFileActionsMenu = function(fileObjectId) {
  var menu = document.createElement('div');
  menu.classList.add('actions-menu','arrow-box');
  menu.setAttribute('id', 'file-actions-' + fileObjectId);
  var menuList = document.createElement('ul');
  var metadataListItem = document.createElement('li');
  var metadataAction = document.createElement('span');
  metadataAction.classList.add('link');
  metadataAction.setAttribute('data-file-id', fileObjectId);
  metadataListItem.appendChild(metadataAction);
  menuList.appendChild(metadataListItem);
  menu.appendChild(menuList);
  return menu;
}


FilesystemBrowser.prototype.generateHeader = function() {
  var header = document.createElement('div');
  header.setAttribute('id','filesystem-browse-header');

  var headerInner = document.createElement('div');
  headerInner.classList.add('inner');

  var title = document.createElement('h1');
  title.classList.add('title');
  title.innerHTML = this.volume['title'];

  var nav = document.createElement('div');
  nav.classList.add('directory-nav');

  var filters = document.createElement('div');
  filters.classList.add('options', 'filters');
  var hiddenFileFilterControl = this.generateFilterControl('hidden');
  var deletedFileFilterControl = this.generateFilterControl('unallocated');
  this.hiddenFileFilterControl = hiddenFileFilterControl;
  this.deletedFileFilterControl = deletedFileFilterControl;

  filters.appendChild(hiddenFileFilterControl);
  filters.appendChild(deletedFileFilterControl);

  var tableHead = this.generateTableHead();
  var tableHeadWrapper = document.createElement('div');
  tableHeadWrapper.setAttribute('id','directory-content-head-wrapper')
  tableHeadWrapper.appendChild(tableHead);

  headerInner.appendChild(title);
  headerInner.appendChild(nav);
  headerInner.appendChild(filters);
  headerInner.appendChild(tableHeadWrapper);
  header.appendChild(headerInner);
  return header;
}


FilesystemBrowser.prototype.generateTableHead = function() {
  var table = document.createElement('table');
  table.classList.add('directory-content-head');

  function generateThElement(options) {
    var th = document.createElement('th');
    var span = document.createElement('span');
    if (options['class']) {
      if ( Array.isArray(options['class']) ) {
        options['class'].forEach(function(c) {
          th.classList.add(c);
        });
      }
      else {
        th.classList.add(options['class']);
      }

    }
    if (options['sort']) {
      th.classList.add('sortable');
      span.classList.add('sort-choice');
      span.setAttribute('data-sort', options['sort']);
    }
    span.innerHTML = options['label'] || '';
    th.appendChild(span);
    return th;
  }

  var thead = document.createElement('thead');
  var tr = document.createElement('tr');
  var iconHead = generateThElement({
    class: 'icon-col'
  });
  var nameHead = generateThElement({
    class: ['name-col','primary-col'],
    sort: 'name',
    label: 'Name'
  });
  this.enableSortControl(nameHead);
  var filesizeHead = generateThElement({
    class: 'filesize-col',
    sort: 'filesize',
    label: 'Size (bytes)'
  });
  this.enableSortControl(filesizeHead);
  var crtimeHead = generateThElement({
    class: 'date-col',
    sort: 'crtime',
    label: 'Created'
  });
  this.enableSortControl(crtimeHead);
  var mtimeHead = generateThElement({
    class: 'date-col',
    sort: 'mtime',
    label: 'Modified'
  });
  this.enableSortControl(mtimeHead);
  tr.appendChild(iconHead);
  tr.appendChild(nameHead);
  tr.appendChild(filesizeHead);
  tr.appendChild(crtimeHead);
  tr.appendChild(mtimeHead);
  thead.appendChild(tr);
  table.appendChild(thead);
  return table;
}


FilesystemBrowser.prototype.enableSortControl = function(th) {
  var _this = this;
  var sortTrigger = th.querySelectorAll('.sort-choice')[0];
  var sortKey = sortTrigger.getAttribute('data-sort');
  var sortDirectionType = (sortKey == 'name') ? 'alpha' : 'numeric';

  function disableActiveSortTrigger() {
    var activeSortTrigger = document.querySelectorAll('.directory-content-head .sort-choice.active')[0];
    var activeSortTriggerParent = activeSortTrigger.parentElement;
    var activeSortDirectionIcon = activeSortTriggerParent.querySelectorAll('.sort-order')[0];
    activeSortTrigger.classList.remove('active');
    activeSortTriggerParent.removeChild(activeSortDirectionIcon);
  }

  function enableSortDirectionControl(element) {
    element.addEventListener('click', function() {
      var sortType = element.getAttribute('data-sort-type');
      var currentDirection = element.getAttribute('data-sort-direction');
      var newDirection = (currentDirection == 'desc') ? 'asc' : 'desc';
      var faClassPrefix = (sortType == 'alpha') ? 'fa-sort-alpha-' : 'fa-sort-numeric-';
      var oldFaClass = faClassPrefix + currentDirection;
      var newFaClass = faClassPrefix + newDirection;
      _this.sortDirection = newDirection;
      _this.applySort();
      _this.updateTableBody();
      this.classList.remove(oldFaClass);
      this.classList.add(newFaClass);
      this.setAttribute('data-sort-direction', newDirection);
    });
  }

  function sortDirectionIcon(type, direction) {
    var icon = document.createElement('i');
    icon.classList.add('sort-order','fa');
    var faClassPrefix = (type == 'alpha') ? 'fa-sort-alpha-' : 'fa-sort-numeric-';
    var faClassSuffix = (direction == 'desc') ? 'desc' : 'asc';
    icon.classList.add(faClassPrefix + faClassSuffix);
    icon.setAttribute('data-sort-direction', direction);
    icon.setAttribute('data-sort-type', type);

    enableSortDirectionControl(icon);

    return icon;
  }

  sortTrigger.addEventListener('click', function() {
    if (!this.classList.contains('active')) {
      disableActiveSortTrigger()
      this.classList.add('active');
      _this.sortKey = sortKey;
      _this.sortDirection = 'asc';
      var directionIcon = sortDirectionIcon(sortDirectionType, 'asc');
      th.appendChild(directionIcon);
      _this.applySort();
      _this.updateTableBody();
    }
  });

  if (sortKey == _this.sortKey) {
    sortTrigger.classList.add('active');
    var directionIcon = sortDirectionIcon(sortDirectionType, 'asc');
    th.appendChild(directionIcon);
  }
}


FilesystemBrowser.prototype.generateTable = function() {
  var table = document.createElement('table');
  table.classList.add('directory-content','filesystem-table');
  var tbody = document.createElement('tbody');
  table.appendChild(tbody);
  return table;
}


FilesystemBrowser.prototype.generateFilterControl = function(filter) {
  var _this = this;
  var showText;
  var hideText;
  switch (filter) {
    case 'unallocated':
      showText = "Show deleted";
      hideText = "Hide deleted";
      break;
    case 'hidden':
      showText = "Show hidden";
      hideText = "Hide hidden";
      break;
  }

  var link = document.createElement('span');
  link.classList.add('link','filter-link', filter);
  var linkText = (this.filters[filter]) ? hideText : showText;
  link.innerHTML = linkText;
  link.addEventListener('click', function() {
    if (!this.classList.contains('disabled')) {
      var newLinkText = (_this.filters[filter]) ? showText : hideText;
      var newFilterValue = (_this.filters[filter]) ? false : true;
      if (this.classList.contains('active')) {
        this.classList.remove('active');
      }
      else {
        this.classList.add('active');
      }
      _this.filters[filter] = newFilterValue;
      _this.filterCurrentDirectoryContents();
      _this.applySort();
      _this.updateTableBody();
      link.innerHTML = newLinkText;
    }
  });
  return link;
}


FilesystemBrowser.prototype.updateDirectoryNav = function() {
  var _this = this;
  var nav = document.querySelectorAll('.directory-nav')[0];
  nav.innerHTML = '';

  function enableDirectoryChange(element, directoryId, index) {
    element.addEventListener('click', function(event) {
      if (index == 0) {
        _this.setCurrentDirectory(_this.volume.root);
        _this.updateTableBody();
        _this.updateFilters();
      }
      else {
        _this.getDirectory(directoryId);
      }
      _this.directoryPath.splice(index + 1, _this.directoryPath.length);
      _this.updateDirectoryNav();
      event.stopPropagation();
    });
  }

  this.directoryPath.forEach(function(segment, index) {
    var span = document.createElement('span');
    span.classList.add('directory-nav-segment');
    var label = (index == 0) ? '[root]' : segment['name'];
    span.innerHTML = label;
    var separator = document.createElement('span');
    separator.classList.add('path-separator');

    if (index < (_this.directoryPath.length - 1)) {
      span.classList.add('link');
      enableDirectoryChange(span, segment['id'], index);
      nav.appendChild(span);
      nav.appendChild(separator);
    }
    else {
      if (_this.directoryPath.length == 1) {
        nav.appendChild(separator);
      }
      else {
        nav.appendChild(span);
      }
    }
  });
}


FilesystemBrowser.prototype.updateTableBody = function() {
  var _this = this;
  var tbody = this.table.querySelectorAll('tbody')[0];
  tbody.innerHTML = '';

  function enableDirectoryChange(element, record) {
    element.addEventListener('click', function() {
      _this.getDirectory(record['id']);
      _this.directoryPath.push( { 'name': record['name'], 'id': record['id']} );
      _this.updateDirectoryNav();
    });
  }

  function generateIconCell(record) {
    var td = document.createElement('td');
    td.classList.add('icon-col');

    var icon = document.createElement('i');
    icon.classList.add('fa');
    var faClass;
    if (record['type'] == 'directory') {
      icon.classList.add('icon-link', 'change-directory', 'link');
      icon.setAttribute('data-directory-id', record['id']);
      faClass = (record['unallocated']) ? 'fa-folder-o' : 'fa-folder';
      enableDirectoryChange(icon, record);
    }
    if (record['type'] == 'file') {
      faClass = (record['unallocated']) ? 'fa-file-o' : 'fa-file';
    }
    icon.classList.add(faClass);
    td.appendChild(icon);

    return td;
  }

  function generateNameCell(record) {
    var td = document.createElement('td');
    td.classList.add('name-col','primary-col');
    var span = document.createElement('span');
    span.innerHTML = record['name'];
    if (record['type'] == 'directory') {
      span.setAttribute('data-directory-id', record['id']);
      span.innerHTML = record['name'];
      if (!record['unallocated']) {
        span.classList.add('change-directory', 'link');
        enableDirectoryChange(span, record);
      }
    }
    else {
      span.setAttribute('data-file-object-id', record['id']);
      if (!record['unallocated'] && record['file_metadata']) {
        span.classList.add('link');
        _this.enableFileActions(span, record);
      }
    }

    if (record['unallocated']) {
      span.classList.add('deleted');
    }

    td.appendChild(span);

    return td;
  }

  function generateSizeCell(record) {
    var td = document.createElement('td');
    td.classList.add('filesize-col');
    var value = (record['type'] != 'directory') ? record['filesize'] : '--';
    td.innerHTML = value;
    return td;
  }

  function generateCrtimeCell(record) {
    var td = document.createElement('td');
    td.classList.add('date-col');
    td.innerHTML = record['crtime'] ? record['crtime'] : '--';
    return td;
  }

  function generateMtimeCell(record) {
    var td = document.createElement('td');
    td.classList.add('date-col');
    td.innerHTML = record['mtime'] ? record['mtime'] : '--';
    return td;
  }

  function generateRow(record) {
    var row = document.createElement('tr');
    var iconCell = generateIconCell(record);
    var nameCell = generateNameCell(record);
    var sizeCell = generateSizeCell(record);
    var crtimeCell = generateCrtimeCell(record);
    var mtimeCell = generateMtimeCell(record);
    row.appendChild(iconCell);
    row.appendChild(nameCell);
    row.appendChild(sizeCell);
    row.appendChild(crtimeCell);
    row.appendChild(mtimeCell);
    return row;
  }

  for (var i = 0; i < this.currentDirectoryContentsFiltered.length; i++) {
    var record = this.currentDirectoryContentsFiltered[i];
    var row = generateRow(record);
    tbody.appendChild(row);
  }

}


FilesystemBrowser.prototype.applyFilters = function(key, value) {
  this.filters[key] = value;

}


FilesystemBrowser.prototype.applySort = function() {
  this.currentDirectoryContentsFiltered = sortArrayOfObjects(this.currentDirectoryContentsFiltered, this.sortKey, this.sortDirection);
}


// modal for file metadata
FilesystemBrowser.prototype.createModal = function(callback) {
  console.log('createModal');
  var _this = this;

  // overlay
  var modalOverlay = document.createElement('div');
  modalOverlay.setAttribute('id','modal-overlay-file-metadata');

  // modal wrapper
  var modalWrapper = document.createElement('div');
  modalWrapper.setAttribute('id','modal-wrapper-file-metadata');

  // modal
  var modal = document.createElement('div');
  modal.setAttribute('id','modal-file-metadata');

  // close link
  var closeLinkWrapper = document.createElement('div');
  closeLinkWrapper.setAttribute('id','file-metadata-close-link');
  var closeLink = document.createElement('span');
  closeLink.classList.add('link');
  closeLink.innerHTML = "CLOSE";

  closeLink.addEventListener('click', function(event) {
    _this.closeModal();
    event.stopPropagation();
    event.preventDefault();
  });
  closeLinkWrapper.appendChild(closeLink);

  modal.appendChild(closeLinkWrapper);
  modalWrapper.appendChild(modal);
  this.rootElement.appendChild(modalOverlay);
  this.rootElement.appendChild(modalWrapper);
  this.modalOverlay = modalOverlay;
  this.modalWrapper = modalWrapper;
  this.modal = modal;
  executeCallback(callback);
}


FilesystemBrowser.prototype.removeModal = function() {
  if (this.modalOverlay) {
    this.modalOverlay.remove();
  }
  if (this.modalWrapper) {
    this.modalWrapper.remove();
  }
}


FilesystemBrowser.prototype.closeModal = function() {
  var _this = this;
  this.modalWrapper.classList.add('fadeout');
  this.modalWrapper.classList.remove('active');
  this.modalOverlay.classList.add('fadeout');
  this.modalOverlay.classList.remove('active');
  this.wrapperParent.style.overflowY = 'scroll';
  this.modalOverlay.addEventListener('animationend',function(event) {
    _this.removeModal();
  });
}


FilesystemBrowser.prototype.openElementInModal = function(element) {
  var _this = this;
  this.createModal();
  this.modal.appendChild(element);
  this.modalOverlay.classList.add('fadein');
  this.modalOverlay.classList.add('active');
  this.modalWrapper.classList.add('fadein');
  this.modalWrapper.classList.add('active');
  this.header.style.visibility = 'visible';
}


FilesystemBrowser.prototype.showFileMetadata = function(record) {
  var _this = this;
  var fileMetadata = record['file_metadata'];

  // console.log(fileMetadata);

  function generateMetadataDisplayElement() {
    var element = document.createElement('div');
    element.classList.add('file-metadata');
    var title = document.createElement('div');
    title.classList.add('title');
    title.innerHTML = record['name'];
    element.appendChild(title);
    var content = document.createElement('div');
    content.classList.add('content');

    for (var key in fileMetadata) {
      if (fileMetadata[key]) {
        var row = document.createElement('div');
        row.classList.add('row');
        var label = document.createElement('div');
        label.classList.add('small-12','medium-4','cell','element-label');
        label.innerHTML = key;
        var value = document.createElement('div');
        value.classList.add('small-12','medium-8','cell','element-value');
        value.innerHTML = fileMetadata[key];
        row.appendChild(label);
        row.appendChild(value);
        content.appendChild(row);
      }
    }

    element.appendChild(content);

    return element;
  }

  var contentElement = generateMetadataDisplayElement();
  this.openElementInModal(contentElement);
}


FilesystemBrowser.prototype.enableFileActions = function(element, record) {
  var _this = this;
  var menuSelector = '.actions-menu';
  this.fileObjectMenuActive = false;
  var html = document.getElementsByTagName('html')[0];

  function generateFileActionsMenu(fileObjectId) {
    var menu = document.createElement('div');
    menu.classList.add('actions-menu','arrow-box');
    menu.setAttribute('id', 'file-actions-' + fileObjectId);
    var menuList = document.createElement('ul');
    var metadataListItem = document.createElement('li');
    var metadataAction = document.createElement('span');
    metadataAction.classList.add('link');
    metadataAction.setAttribute('data-file-id', fileObjectId);
    metadataAction.innerHTML = "View file metadata";
    metadataAction.addEventListener('click', function(event) {
      removeActiveMenu();
      _this.showFileMetadata(record);
      event.stopPropagation();
    });
    metadataListItem.appendChild(metadataAction);
    menuList.appendChild(metadataListItem);
    menu.appendChild(menuList);
    return menu;
  }

  function removeActiveMenu() {
    console.log('removeActiveMenu');
    var activeMenu = document.querySelectorAll(menuSelector + '.active')[0];
    if (activeMenu) {
      removeNode(activeMenu);
      _this.fileObjectMenuActive = false;
    }
  }

  function getOffsetTopRelativeToAncestor(element, ancestorElement) {
    var ancestorElementId = ancestorElement.getAttribute('id');
    offset = 0;
    offset = offset + element.offsetTop;
    var parent = element.offsetParent;
    var parentId = parent.getAttribute('id');

    while (parentId != ancestorElementId) {
      offset = offset + parent.offsetTop;
      parent = parent.offsetParent;
      parentId = parent.getAttribute('id');
    }
    return offset;
  }

  function getOffsetLeftRelativeToAncestor(element, ancestorElement) {
    var ancestorElementId = ancestorElement.getAttribute('id');
    offset = 0;
    offset = offset + element.offsetLeft;
    var parent = element.offsetParent;
    var parentId = parent.getAttribute('id');

    while (parentId != ancestorElementId) {
      offset = offset + parent.offsetLeft;
      parent = parent.offsetParent;
      parentId = parent.getAttribute('id');
    }
    return offset;
  }

  function showMenu() {
    // remove any menus already visible
    removeActiveMenu();
    var wrapper = _this.wrapper;
    var elementOffsetTop = getOffsetTopRelativeToAncestor(element, wrapper);
    var elementOffsetLeft = getOffsetLeftRelativeToAncestor(element, wrapper);
    var fileObjectId = element.getAttribute('data-file-object-id');
    var elementBottom = elementOffsetTop + element.offsetHeight;
    var elementLeft = elementOffsetLeft;
    var menu = generateFileActionsMenu(fileObjectId);
    menu.classList.add('active');
    menu.style.top = elementBottom + 'px';
    menu.style.left = elementLeft + 'px';
    wrapper.appendChild(menu);
    _this.fileObjectMenuActive = true;
  }

  element.addEventListener('click', function(event) {
    if (_this.fileObjectMenuActive) {
      removeActiveMenu();
    }
    else {
      showMenu();
      event.stopPropagation();
      event.preventDefault();
    }
  });

  html.addEventListener('click', function(event) {
    var menu = document.querySelectorAll(menuSelector + '.active')[0];
    if (menu) {
      if (targetInElement(menu, event.target)) {
        console.log('clicked inside');
      } else {
        console.log('clicked outside');
        removeActiveMenu();
      }
    }
  });
}
