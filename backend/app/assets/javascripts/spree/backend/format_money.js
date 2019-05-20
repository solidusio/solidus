//= require spree/backend/translation
//= require solidus_admin/accounting

Spree.formatMoney = function(amount, currency) {
  var currencyInfo = Spree.currencyInfo[currency];

  var thousand = Spree.t('currency_delimiter');
  var decimal = Spree.t('currency_separator');

  return accounting.formatMoney(amount, currencyInfo[0], currencyInfo[1], thousand, decimal, currencyInfo[2]);
}
