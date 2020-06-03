function showMore() {
  document.querySelectorAll('.show-more').forEach(function(element) {
    var triggers = element.querySelectorAll('.trigger');
    var textShort = element.querySelector('.text-short');
    var textLong = element.querySelector('.text-long');

    triggers.forEach(function(trigger) {
      trigger.addEventListener('click', function(event) {
        if (element.classList.contains('open')) {
          hide(textLong);
          show(textShort);
          element.classList.remove('open');
        }
        else {
          show(textLong);
          hide(textShort);
          element.classList.add('open');
        }
      });
    });
  });
}
