class NumberWithCurrency extends HTMLElement {
  connectedCallback() {
    this.currencySelector = this.querySelector('.number-with-currency-select');
    this.render()
    this.addEventListener('change', this);
  }

  handleEvent() {
    this.render()
  }

  get currency() {
    if (this.currencySelector) {
      return this.currencySelector.value;
    } else {
      return this.querySelector('.number-with-currency-addon')?.dataset?.currency;
    }
  }

  get currencySymbol() {
    const currency = this.currency;
    if (currency) {
      const currencyInfo = Spree.currencyInfo[currency];
      return currencyInfo[0];
    } else {
      return '';
    }
  }

  render() {
    this.querySelector('.number-with-currency-symbol').textContent = this.currencySymbol;
  }
}

customElements.define('number-with-currency', NumberWithCurrency);
