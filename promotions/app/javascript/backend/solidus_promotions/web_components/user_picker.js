class UserPicker extends HTMLInputElement {
  connectedCallback() {
    $(this).userAutocomplete();
  }
}

customElements.define('user-picker', UserPicker, { extends: 'input' });
