function Modal(config) {
  var _this = this;
  this.initialize(config);
}


Modal.prototype.initialize = function(config) {
  var body = document.querySelectorAll('body')[0];
  this.body = body;
  this.create();
}


Modal.prototype.create = function() {
  var _this = this;
  var modalOverlay = document.querySelectorAll('#modal-overlay')[0];
  if (!modalOverlay) {
    modalOverlay = document.createElement('div');
    modalOverlay.setAttribute('id','modal-overlay');
    this.body.appendChild(modalOverlay);
  }

  var modalWrapper = document.querySelectorAll('#modal-wrapper')[0];
  if (!modalWrapper) {
    modalWrapper = document.createElement('div');
    modalWrapper.setAttribute('id','modal-wrapper');
    this.body.appendChild(modalWrapper);
  }

  var modal = modalWrapper.querySelectorAll('#modal')[0];
  if (!modal) {
    modal = document.createElement('div');
    modal.setAttribute('id','modal');
    modalWrapper.appendChild(modal);
  }

  var contentWrapper = modal.querySelectorAll('.modal-content')[0];
  if (!contentWrapper) {
    contentWrapper = document.createElement('div');
    contentWrapper.setAttribute('id', 'modal-content');
    modal.appendChild(contentWrapper);
  }

  var closeLinkWrapper = document.createElement('div');
  closeLinkWrapper.classList.add('close-link');
  var closeLink = document.createElement('span');
  closeLink.classList.add('link');
  closeLink.innerHTML = "CLOSE";
  closeLink.addEventListener('click', function() {
    _this.close();
  });
  closeLinkWrapper.appendChild(closeLink);

  modal.appendChild(closeLinkWrapper);

  this.modalOverlay = modalOverlay;
  this.modalWrapper = modalWrapper;
  this.modal = modal;
  this.contentWrapper = contentWrapper;
}


Modal.prototype.removeModal = function() {
  if (this.modalOverlay) {
    this.modalOverlay.remove();
  }
  if (this.modalWrapper) {
    this.modalWrapper.remove();
  }
}


Modal.prototype.close = function() {
  var _this = this;
  this.modalWrapper.classList.add('fadeout');
  this.modalWrapper.classList.remove('active');
  this.modalOverlay.classList.add('fadeout');
  this.modalOverlay.classList.remove('active');
  this.modalOverlay.addEventListener('animationend',function(event) {
    _this.body.style.overflowY = 'scroll';
    _this.removeModal();
  });
}


Modal.prototype.open = function(options) {
  var _this = this;
  var element;

  options['mode'] = options['mode'] ? options['mode'] : 'text';

  var appendAs = 'element';
  var content;
  switch (options['mode']) {
    case 'text':
      content = options['content'];
      if (!content) {
        console.log('No content provided');
        content = '';
      }
      appendAs = 'html';
      break;
    case 'element':
      var element = options['element'];
      if (!element) {
        console.log('No element provided');
        element = document.createElement('div');
        element.innerHTML = '';
      }
      break;
    case 'iframe':
      var element = document.createElement('iframe');
      if (options['iframeAttributes']) {
        for (var key in options['iframeAttributes']) {
          element.setAttribute(key, options['iframeAttributes'][key]);
        }
      }
      else {
        console.log('No iframe attributes provided');
      }
      break;
  }

  this.body.style.overflow = 'hidden';
  this.contentWrapper.innerHTML = '';

  if (appendAs == 'element') {
    this.contentWrapper.appendChild(element);
  }
  else if (appendAs == 'html') {
    this.contentWrapper.innerHTML = content;
  }

  this.modalOverlay.style.top = window.scrollY + 'px';
  this.modalOverlay.style.visibility = 'visible';
  this.modalOverlay.classList.add('fadein');
  this.modalOverlay.classList.add('active');

  this.modalWrapper.style.top = window.scrollY + 'px';
  this.modalWrapper.style.visibility = 'visible';
  this.modalWrapper.classList.add('fadein');
  this.modalWrapper.classList.add('active');

  var html = document.getElementsByTagName('html')[0];
  html.addEventListener('click', function(event) {
    if (targetInElement(_this.modal, event.target)) {
      console.log('clicked inside');
    } else {
      console.log('clicked outside');
      _this.close();
    }
  });

  if (options['callback'] && options['callback'] !== 'undefined') {
    options['callback']();
  }
}
