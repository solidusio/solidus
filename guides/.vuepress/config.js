module.exports = {
  title: 'Solidus Guides',
  description: 'Developer Guidelines for Solidus',
  base: '/solidus/',
  themeConfig: {
    repo: 'solidusio/solidus',
    editLinks: true,
    docsDir: 'guides',
    nav: [
      { text: 'Home', link: '/' }
    ],
    sidebar: [
      {
        title: 'Getting Started',
        collapsable: true,
        children: [
          '/getting-started/first-time-installation',
          '/getting-started/installation-options',
          '/getting-started/develop-solidus',
          '/getting-started/forking-solidus'
        ]
      },
      {
        title: 'Preferences',
        collapsable: true,
        children: [
          '/preferences/app-configuration',
          '/preferences/add-model-preferences',
          '/preferences/class-extension-points'
        ]
      },
      {
        title: 'Locations',
        collapsable: true,
        children: [
          '/locations/',
          '/locations/zones',
          '/locations/countries-and-states'
        ]
      },
      {
        title: 'Payments',
        collapsable: true,
        children: [
          '/payments/overview',
          '/payments/payments',
          '/payments/payment-methods',
          '/payments/payment-sources',
          '/payments/payment_processing',
          '/payments/payment-service-providers',
          '/payments/custom_gateway'
        ]
      },
      {
        title: 'Taxation',
        collapsable: true,
        children: [
          '/taxation/overview-of-taxation',
          '/taxation/displaying-prices',
          '/taxation/value-added-tax',
          '/taxation/example-tax-setups',
          '/taxation/custom-tax-calculators'
        ]
      },
      {
        title: 'Shipments',
        collapsable: true,
        children: [
          '/shipments/overview-of-shipments',
          '/shipments/user-interface-for-shipments',
          '/shipments/split-shipments',
          '/shipments/cartons',
          '/shipments/shipping-method-filters',
          '/shipments/shipment-setup-examples',
          '/shipments/solidus-active-shipping-extension',
          '/shipments/custom-shipping-calculators'
        ]
      },
      {
        title: 'Calculators',
        collapsable: true,
        children: [
          '/calculators/overview',
          '/calculators/promotion-calculators',
          '/calculators/shipping-calculators',
          '/calculators/tax-calculator'
        ]
      },
      {
        title: 'Assets',
        collapsable: true,
        children: [
          '/assets/override-solidus-assets',
          '/assets/asset-management'
        ]
      },
      {
        title: 'Views',
        collapsable: true,
        children: [
          '/views/custom-frontend',
          '/views/override-views'
        ]
      },
      {
        title: 'Products and Variants',
        collapsable: true,
        children: [
          '/products-and-variants/overview',
          '/products-and-variants/products',
          '/products-and-variants/variants',
          '/products-and-variants/product-images',
          '/products-and-variants/product-properties',
          '/products-and-variants/multi-currency-support',
          '/products-and-variants/taxonomies-and-taxons'
        ]
      },
      {
        title: 'Inventory',
        collapsable: true,
        children: [
          '/inventory/overview',
          '/inventory/inventory-units',
          '/inventory/stock-items',
          '/inventory/stock-movements'
        ]
      },
      {
        title: 'Returns',
        collapsable: true,
        children: [
          '/returns/overview',
          '/returns/return-authorizations',
          '/returns/customer-returns',
          '/returns/return-items',
          '/returns/reimbursements',
          '/returns/reimbursement-types'
        ]
      },
      {
        title: 'Promotions',
        collapsable: true,
        children: [
          '/promotions/overview',
          '/promotions/promotion-rules',
          '/promotions/promotion-actions',
          '/promotions/promotion-handlers'
        ]
      },
      {
        title: 'Adjustments',
        collapsable: true,
        children: [
          '/adjustments/overview'
        ]
      },
      {
        title: 'Orders',
        collapsable: true,
        children: [
          '/orders/overview',
          '/orders/order-state-machine',
          '/orders/update-orders',
          '/orders/display-total-methods'
        ]
      },
      {
        title: 'Returns',
        collapsable: true,
        children: [
          '/returns/return-authorizations'
        ]
      },
      {
        title: 'Users',
        collapsable: true,
        children: [
          '/users/addresses'
        ]
      },
      {
        title: 'Upgrades',
        collapsable: true,
        children: [
          '/upgrades/overview',
          '/upgrades/migrate-from-spree',
          '/upgrades/versioning-guidelines'
        ]
      },
      {
        title: 'Extensions',
        collapsable: true,
        children: [
          '/extensions/installing-extensions',
          '/extensions/decorators',
          '/extensions/testing-extensions'
        ]
      }
    ]
  }
};
