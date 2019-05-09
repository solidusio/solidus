# Orders

Orders through the API will only be visible to admins and the users who own
them. If a user attempts to access an order that does not belong to them, they
will be met with an authorization error.

## Cancel

To cancel an order, make a request using that order's number:

```text
PUT /api/orders/R123456789
```

### Successful response

**Response code** 200

```json
{
  "id": 1,
  "number": "R123456789",
  "item_total": "0.0",
  "total": "0.0",
  "ship_total": "0.0",
  "state": "canceled",
  "adjustment_total": "0.0",
  "user_id": 1,
  "created_at": "2019-03-06T04:56:13.553Z",
  "updated_at": "2019-03-06T04:56:13.807Z",
  "completed_at": "2019-03-06T04:56:13.584Z",
  "payment_total": "0.0",
  "shipment_state": nil,
  "payment_state": "void",
  "email": "email1@example.com",
  "special_instructions": nil,
  "channel": "spree",
  "included_tax_total": "0.0",
  "additional_tax_total": "0.0",
  "display_included_tax_total": "$0.00",
  "display_additional_tax_total": "$0.00",
  "tax_total": "0.0",
  "currency": "USD",
  "covered_by_store_credit": true,
  "display_total_applicable_store_credit": "$0.00",
  "order_total_after_store_credit": "0.0",
  "display_order_total_after_store_credit": "$0.00",
  "total_applicable_store_credit": "0.0",
  "display_total_available_store_credit": "$0.00",
  "display_store_credit_remaining_after_capture": "$0.00",
  "canceler_id": 1001,
  "display_item_total": "$0.00",
  "total_quantity": 0,
  "display_total": "$0.00",
  "display_ship_total": "$0.00",
  "display_tax_total": "$0.00",
  "token": "PnFXohFBboqaJ1YYHwH93g",
  "checkout_steps":
[
    "address",
    "delivery",
    "confirm",
    "complete"
  ],
  "payment_methods": [],
  "bill_address":
{
    "id": 1,
    "firstname": "John",
    "lastname": nil,
    "full_name": "John",
    "address1": "PO Box 1337",
    "address2": "Northwest",
    "city": "Herndon",
    "zipcode": "10001",
    "phone": "555-555-0199",
    "company": "Company",
    "alternative_phone": "555-555-0199",
    "country_id": 1,
    "country_iso": "US",
    "state_id": 1,
    "state_name": nil,
    "state_text": "AL",
    "country":
  {
      "id": 1,
      "iso_name": "UNITED STATES",
      "iso": "US",
      "iso3": "USA",
      "name": "United States",
      "numcode": 840
    },
    "state":
  {
      "id": 1,
      "name": "Alabama",
      "abbr": "AL",
      "country_id": 1
    }
  },
  "ship_address":
{
    "id": 2,
    "firstname": "John",
    "lastname": nil,
    "full_name": "John",
    "address1": "A Different Road",
    "address2": "Northwest",
    "city": "Herndon",
    "zipcode": "10002",
    "phone": "555-555-0199",
    "company": "Company",
    "alternative_phone": "555-555-0199",
    "country_id": 1,
    "country_iso": "US",
    "state_id": 1,
    "state_name": nil,
    "state_text": "AL",
    "country":
  {
      "id": 1,
      "iso_name": "UNITED STATES",
      "iso": "US",
      "iso3": "USA",
      "name": "United States",
      "numcode": 840
    },
    "state":
  {
      "id": 1,
      "name": "Alabama",
      "abbr": "AL",
      "country_id": 1
    }
  },
  "line_items": [],
  "payments": [],
  "shipments": [],
  "adjustments": [],
  "permissions": {
  },
  "credit_cards": []
}
```

### Failed response

**Response code** 422

```json
{
  "error": "You are not authorized to perform that action."
}
```

## Create

To create a new order through the API, make this request:

```text
POST /api/orders
```

If you wish to create an order with a line item matching to a variant whose ID is `1` and quantity is `5`, make this request:

```text
POST /api/orders
```

```json
{
  "order": {
    "line_items": {
      "0": {
        "variant_id": 1,
        "quantity": 5
      }
    }
  }
}
```

### Successful response

**Response code** 201

```json
{
  "id": 2,
  "number": "R977038898",
  "item_total": "99.95",
  "total": "99.95",
  "ship_total": "0.0",
  "state": "cart",
  "adjustment_total": "0.0",
  "user_id": nil,
  "created_at": "2019-03-06T05:53:49.319Z",
  "updated_at": "2019-03-06T05:53:49.412Z",
  "completed_at": nil,
  "payment_total": "0.0",
  "shipment_state": nil,
  "payment_state": nil,
  "email": nil,
  "special_instructions": nil,
  "channel": "spree",
  "included_tax_total": "0.0",
  "additional_tax_total": "0.0",
  "display_included_tax_total": "$0.00",
  "display_additional_tax_total": "$0.00",
  "tax_total": "0.0",
  "currency": "USD",
  "covered_by_store_credit": false,
  "display_total_applicable_store_credit": "$0.00",
  "order_total_after_store_credit": "99.95",
  "display_order_total_after_store_credit": "$99.95",
  "total_applicable_store_credit": 0.0,
  "display_total_available_store_credit": "$0.00",
  "display_store_credit_remaining_after_capture": "$0.00",
  "canceler_id": nil,
  "display_item_total": "$99.95",
  "total_quantity": 5,
  "display_total": "$99.95",
  "display_ship_total": "$0.00",
  "display_tax_total": "$0.00",
  "token": "ABn031jFbeblKvoWRBV7BQ",
  "checkout_steps": [
    "address",
    "delivery",
    "payment",
    "confirm",
    "complete"
  ],
  "payment_methods": [],
  "bill_address": nil,
  "ship_address": nil,
  "line_items":
   [
    {
      "id": 1,
      "quantity": 5,
      "price": "19.99",
      "variant_id": 1,
      "single_display_amount": "$19.99",
      "display_amount": "$99.95",
      "total": "99.95",
      "variant":
      {
        "id": 2,
        "name": "Product #1 - 7573",
        "sku": "SKU-1",
        "weight": "0.0",
        "height": nil,
        "width": nil,
        "depth": nil,
        "is_master": false,
        "slug": "product-1-7573",
        "description": "As seen on TV!",
        "track_inventory": true,
        "price": "19.99",
        "display_price": "$19.99",
        "options_text": "Size: S",
        "in_stock": false,
        "is_backorderable": true,
        "total_on_hand": 0,
        "is_destroyed": false,
        "option_values": [
          {
            "id": 1,
            "name": "Size-1",
            "presentation": "S",
            "option_type_name": "foo-size-1",
            "option_type_id": 1,
            "option_type_presentation": "Size"
          }
        ],
        "images": [],
        "product_id": 1
      },
      "adjustments": []
    }
  ],
  "payments": [],
  "shipments": [],
  "adjustments": [],
  "permissions": {
    "can_update": false
  },
  "credit_cards": []
}
```

### Failed response

If a `variant_id` is passed that does not exist an error will be returned.

**Response code** 404

```json
{
  "error": "The resource you were looking for could not be found."
}
```

## Empty

To empty an order, make a request using that order's number:

```text
PUT /api/orders/R123456789/empty
```

### Successful response

**Response code** 204

### Failed response

**Response code** 422

```json
{
  "error": "You are not authorized to perform that action."
}
```

## Index

A searchable, paginated list of orders is available through the index endpoint.
This supports [Ransack](https://github.com/activerecord-hackery/ransack) attributes and pagination.

```text
GET /api/orders
```

### Successful response

**Response code** 200

```json
{
  "orders": [
    {
      "id": 1,
      "number": "R836616645",
      "item_total": "0.0",
      "total": "0.0",
      "ship_total": "0.0",
      "state": "cart",
      "adjustment_total": "0.0",
      "user_id": 1,
      "created_at": "2019-05-09T22:26:51.769Z",
      "updated_at": "2019-05-09T22:26:51.769Z",
      "completed_at": null,
      "payment_total": "0.0",
      "shipment_state": null,
      "payment_state": null,
      "email": "email1@example.com",
      "special_instructions": null,
      "channel": "spree",
      "included_tax_total": "0.0",
      "additional_tax_total": "0.0",
      "display_included_tax_total": "$0.00",
      "display_additional_tax_total": "$0.00",
      "tax_total": "0.0",
      "currency": "USD",
      "covered_by_store_credit": true,
      "display_total_applicable_store_credit": "$0.00",
      "order_total_after_store_credit": "0.0",
      "display_order_total_after_store_credit": "$0.00",
      "total_applicable_store_credit": "0.0",
      "display_total_available_store_credit": "$0.00",
      "display_store_credit_remaining_after_capture": "$0.00",
      "canceler_id": null,
      "display_item_total": "$0.00",
      "total_quantity": 0,
      "display_total": "$0.00",
      "display_ship_total": "$0.00",
      "display_tax_total": "$0.00",
      "token": "Mgz97CxeogKAIQsPzYwlbw",
      "checkout_steps": [
        "address",
        "delivery",
        "confirm",
        "complete"
      ]
    },
    {
      "id": 2,
      "number": "R126856208",
      "item_total": "0.0",
      "total": "0.0",
      "ship_total": "0.0",
      "state": "cart",
      "adjustment_total": "0.0",
      "user_id": 2,
      "created_at": "2019-05-09T22:26:51.812Z",
      "updated_at": "2019-05-09T22:26:51.812Z",
      "completed_at": null,
      "payment_total": "0.0",
      "shipment_state": null,
      "payment_state": null,
      "email": "email2@example.com",
      "special_instructions": null,
      "channel": "spree",
      "included_tax_total": "0.0",
      "additional_tax_total": "0.0",
      "display_included_tax_total": "$0.00",
      "display_additional_tax_total": "$0.00",
      "tax_total": "0.0",
      "currency": "USD",
      "covered_by_store_credit": true,
      "display_total_applicable_store_credit": "$0.00",
      "order_total_after_store_credit": "0.0",
      "display_order_total_after_store_credit": "$0.00",
      "total_applicable_store_credit": "0.0",
      "display_total_available_store_credit": "$0.00",
      "display_store_credit_remaining_after_capture": "$0.00",
      "canceler_id": null,
      "display_item_total": "$0.00",
      "total_quantity": 0,
      "display_total": "$0.00",
      "display_ship_total": "$0.00",
      "display_tax_total": "$0.00",
      "token": "Mz2GGtyyaC29H8a1lGRn6Q",
      "checkout_steps": [
        "address",
        "delivery",
        "confirm",
        "complete"
      ]
    }
  ],
  "count": 2,
  "total_count": 2,
  "current_page": 1,
  "pages": 1,
  "per_page": 25
}
```

### Failed response

If no user is authenticated an error is returned.

**Response code** 422

```json
{
  "error": "You are not authorized to perform that action."
}
```

## Current

If you don't know the order number for the current user make this request:

```text
GET /api/orders/current
```

### Successful response

**Response code** 200

```json
{
  "id": 1,
  "number": "R494580429",
  "item_total": "0.0",
  "total": "0.0",
  "ship_total": "0.0",
  "state": "cart",
  "adjustment_total": "0.0",
  "user_id": 2,
  "created_at": "2019-03-06T06:14:02.036Z",
  "updated_at": "2019-03-06T06:14:02.042Z",
  "completed_at": nil,
  "payment_total": "0.0",
  "shipment_state": nil,
  "payment_state": nil,
  "email": "email2@example.com",
  "special_instructions": nil,
  "channel": "spree",
  "included_tax_total": "0.0",
  "additional_tax_total": "0.0",
  "display_included_tax_total": "$0.00",
  "display_additional_tax_total": "$0.00",
  "tax_total": "0.0",
  "currency": "USD",
  "covered_by_store_credit": true,
  "display_total_applicable_store_credit": "$0.00",
  "order_total_after_store_credit": "0.0",
  "display_order_total_after_store_credit": "$0.00",
  "total_applicable_store_credit": "0.0",
  "display_total_available_store_credit": "$0.00",
  "display_store_credit_remaining_after_capture": "$0.00",
  "canceler_id": nil,
  "display_item_total": "$0.00",
  "total_quantity": 1,
  "display_total": "$0.00",
  "display_ship_total": "$0.00",
  "display_tax_total": "$0.00",
  "token": "0suTbW3Z1kmz-YmuIWGzBw",
  "checkout_steps": [
    "address",
    "delivery",
    "confirm",
    "complete"
  ],
  "payment_methods": [],
  "bill_address":
   {
    "id": 3,
    "firstname": "John",
    "lastname": nil,
    "full_name": "John",
    "address1": "PO Box 1337",
    "address2": "Northwest",
    "city": "Herndon",
    "zipcode": "10003",
    "phone": "555-555-0199",
    "company": "Company",
    "alternative_phone": "555-555-0199",
    "country_id": 1,
    "country_iso": "US",
    "state_id": 1,
    "state_name": nil,
    "state_text": "AL",
    "country": {
      "id": 1,
      "iso_name": "UNITED STATES",
      "iso": "US",
      "iso3": "USA",
      "name": "United States",
      "numcode": 840
    },
    "state": {
      "id": 1,
      "name": "Alabama",
      "abbr": "AL",
      "country_id": 1
    }
  },
  "ship_address":
   {
    "id": 4,
    "firstname": "John",
    "lastname": nil,
    "full_name": "John",
    "address1": "A Different Road",
    "address2": "Northwest",
    "city": "Herndon",
    "zipcode": "10004",
    "phone": "555-555-0199",
    "company": "Company",
    "alternative_phone": "555-555-0199",
    "country_id": 1,
    "country_iso": "US",
    "state_id": 1,
    "state_name": nil,
    "state_text": "AL",
    "country": {
      "id": 1,
      "iso_name": "UNITED STATES",
      "iso": "US",
      "iso3": "USA",
      "name": "United States",
      "numcode": 840
    },
    "state": {
      "id": 1,
      "name": "Alabama",
      "abbr": "AL",
      "country_id": 1
    }
  },
  "line_items":
   [
    {
      "id": 1,
      "quantity": 1,
      "price": "10.0",
      "variant_id": 1,
      "single_display_amount": "$10.00",
      "display_amount": "$10.00",
      "total": "10.0",
      "variant":
      {
        "id": 1,
        "name": "Product #1 - 5266",
        "sku": "SKU-1",
        "weight": "0.0",
        "height": nil,
        "width": nil,
        "depth": nil,
        "is_master": true,
        "slug": "product-1-5266",
        "description": "As seen on TV!",
        "track_inventory": true,
        "price": "19.99",
        "display_price": "$19.99",
        "options_text": "",
        "in_stock": false,
        "is_backorderable": true,
        "total_on_hand": 0,
        "is_destroyed": false,
        "option_values": [],
        "images": [],
        "product_id": 1
      },
      "adjustments": []
    }
  ],
  "payments": [],
  "shipments": [],
  "adjustments": [],
  "permissions": {
    "can_update": true
  },
  "credit_cards": []
}
```

If there is no order an empty response is returned

**Response code** 204

## Mine

Returns all orders for the current user. This supports [Ransack](https://rollbar.com/deseretbook/oracle_api/items/36/) attributes and pagination.

```text
POST /api/orders/mine
```

### Successful response

**Response code** 200

```json
{
  "orders":
  [
    {
      "id": 1,
      "number": "R699938235",
      "item_total": "0.0",
      "total": "0.0",
      "ship_total": "0.0",
      "state": "cart",
      "adjustment_total": "0.0",
      "user_id": 2,
      "created_at": "2019-03-13T05:16:20.118Z",
      "updated_at": "2019-03-13T05:16:20.124Z",
      "completed_at": nil,
      "payment_total": "0.0",
      "shipment_state": nil,
      "payment_state": nil,
      "email": "email2@example.com",
      "special_instructions": nil,
      "channel": "spree",
      "included_tax_total": "0.0",
      "additional_tax_total": "0.0",
      "display_included_tax_total": "$0.00",
      "display_additional_tax_total": "$0.00",
      "tax_total": "0.0",
      "currency": "USD",
      "covered_by_store_credit": true,
      "display_total_applicable_store_credit": "$0.00",
      "order_total_after_store_credit": "0.0",
      "display_order_total_after_store_credit": "$0.00",
      "total_applicable_store_credit": "0.0",
      "display_total_available_store_credit": "$0.00",
      "display_store_credit_remaining_after_capture": "$0.00",
      "canceler_id": nil,
      "display_item_total": "$0.00",
      "total_quantity": 1,
      "display_total": "$0.00",
      "display_ship_total": "$0.00",
      "display_tax_total": "$0.00",
      "token": "MwrVcCMnZ8FIROmuz8sxzg",
      "checkout_steps": [
        "address",
        "delivery",
        "confirm",
        "complete"
      ],
      "payment_methods": [],
      "bill_address":
    {
        "id": 3,
        "firstname": "John",
        "lastname": nil,
        "full_name": "John",
        "address1": "PO Box 1337",
        "address2": "Northwest",
        "city": "Herndon",
        "zipcode": "10003",
        "phone": "555-555-0199",
        "company": "Company",
        "alternative_phone": "555-555-0199",
        "country_id": 1,
        "country_iso": "US",
        "state_id": 1,
        "state_name": nil,
        "state_text": "AL",
        "country": {
          "id": 1,
          "iso_name": "UNITED STATES",
          "iso": "US",
          "iso3": "USA",
          "name": "United States",
          "numcode": 840
        },
        "state": {
          "id": 1,
          "name": "Alabama",
          "abbr": "AL",
          "country_id": 1
        }
      },
      "ship_address":
    {
        "id": 4,
        "firstname": "John",
        "lastname": nil,
        "full_name": "John",
        "address1": "A Different Road",
        "address2": "Northwest",
        "city": "Herndon",
        "zipcode": "10004",
        "phone": "555-555-0199",
        "company": "Company",
        "alternative_phone": "555-555-0199",
        "country_id": 1,
        "country_iso": "US",
        "state_id": 1,
        "state_name": nil,
        "state_text": "AL",
        "country": {
          "id": 1,
          "iso_name": "UNITED STATES",
          "iso": "US",
          "iso3": "USA",
          "name": "United States",
          "numcode": 840
        },
        "state": {
          "id": 1,
          "name": "Alabama",
          "abbr": "AL",
          "country_id": 1
        }
      },
      "line_items":
    [
        {
          "id": 1,
          "quantity": 1,
          "price": "10.0",
          "variant_id": 1,
          "single_display_amount": "$10.00",
          "display_amount": "$10.00",
          "total": "10.0",
          "variant":
        {
            "id": 1,
            "name": "Product #1 - 6403",
            "sku": "SKU-1",
            "weight": "0.0",
            "height": nil,
            "width": nil,
            "depth": nil,
            "is_master": true,
            "slug": "product-1-6403",
            "description": "As seen on TV!",
            "track_inventory": true,
            "price": "19.99",
            "display_price": "$19.99",
            "options_text": "",
            "in_stock": false,
            "is_backorderable": true,
            "total_on_hand": 0,
            "is_destroyed": false,
            "option_values": [],
            "images": [],
            "product_id": 1
          },
          "adjustments": []
        }
      ],
      "payments": [],
      "shipments": [],
      "adjustments": [],
      "permissions": {
        "can_update": true
      },
      "credit_cards": []
    }
  ],
  "count": 1,
  "total_count": 1,
  "current_page": 1,
  "pages": 1,
  "per_page": 25
}
```

### Failed response

If no user is authenticated an error is returned.

**Response code** 401

```json
{
  "error": "You must specify an API key."
}
```
