//= require_self
//= require checkout/address

Solidus.disableSaveOnClick = () => {
  const form = document.querySelector('form.edit_order');
  form.addEventListener('submit', () => {
    const elements = form.querySelectorAll('[type="submit"], [type="image"]');
    elements.forEach(element => {
      element.setAttribute('disabled', true);
      element.classList.remove('primary');
      element.classList.add('disabled');
    });
  });
};

window.addEventListener('DOMContentLoaded', () => {
  const termsCheckbox = document.getElementById('accept_terms_and_conditions');

  if (termsCheckbox) {
    const form = termsCheckbox.closest('form');
    const submitButton = form.querySelector('[type="submit"]');
    form.onsubmit = function () {
      if (termsCheckbox.checked) {
        submitButton.innerHTML = 'Submitting...';
        return true;
      } else {
        alert('Please review and accept the Terms of Service');
        submitButton.removeAttribute('disabled');
        submitButton.classList.remove('disabled');
        return false;
      };
    };
  };
});
