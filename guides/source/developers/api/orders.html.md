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
  "id"=>1,
  "number"=>"R458550505",
  "item_total"=>"0.0",
  "total"=>"0.0",
  "ship_total"=>"0.0",
  "state"=>"canceled",
  "adjustment_total"=>"0.0",
  "user_id"=>1,
  "created_at"=>"2019-03-06T04:56:13.553Z",
  "updated_at"=>"2019-03-06T04:56:13.807Z",
  "completed_at"=>"2019-03-06T04:56:13.584Z",
  "payment_total"=>"0.0",
  "shipment_state"=>nil,
  "payment_state"=>"void",
  "email"=>"email1@example.com",
  "special_instructions"=>nil,
  "channel"=>"spree",
  "included_tax_total"=>"0.0",
  "additional_tax_total"=>"0.0",
  "display_included_tax_total"=>"$0.00",
  "display_additional_tax_total"=>"$0.00",
  "tax_total"=>"0.0",
  "currency"=>"USD",
  "covered_by_store_credit"=>true,
  "display_total_applicable_store_credit"=>"$0.00",
  "order_total_after_store_credit"=>"0.0",
  "display_order_total_after_store_credit"=>"$0.00",
  "total_applicable_store_credit"=>"0.0",
  "display_total_available_store_credit"=>"$0.00",
  "display_store_credit_remaining_after_capture"=>"$0.00",
  "canceler_id"=>1001,
  "display_item_total"=>"$0.00",
  "total_quantity"=>0,
  "display_total"=>"$0.00",
  "display_ship_total"=>"$0.00",
  "display_tax_total"=>"$0.00",
  "token"=>"PnFXohFBboqaJ1YYHwH93g",
  "checkout_steps"=>
[
    "address",
    "delivery",
    "confirm",
    "complete"
  ],
  "payment_methods"=>[],
  "bill_address"=>
{
    "id"=>1,
    "firstname"=>"John",
    "lastname"=>nil,
    "full_name"=>"John",
    "address1"=>"PO Box 1337",
    "address2"=>"Northwest",
    "city"=>"Herndon",
    "zipcode"=>"10001",
    "phone"=>"555-555-0199",
    "company"=>"Company",
    "alternative_phone"=>"555-555-0199",
    "country_id"=>1,
    "country_iso"=>"US",
    "state_id"=>1,
    "state_name"=>nil,
    "state_text"=>"AL",
    "country"=>
  {
      "id"=>1,
      "iso_name"=>"UNITED STATES",
      "iso"=>"US",
      "iso3"=>"USA",
      "name"=>"United States",
      "numcode"=>840
    },
    "state"=>
  {
      "id"=>1,
      "name"=>"Alabama",
      "abbr"=>"AL",
      "country_id"=>1
    }
  },
  "ship_address"=>
{
    "id"=>2,
    "firstname"=>"John",
    "lastname"=>nil,
    "full_name"=>"John",
    "address1"=>"A Different Road",
    "address2"=>"Northwest",
    "city"=>"Herndon",
    "zipcode"=>"10002",
    "phone"=>"555-555-0199",
    "company"=>"Company",
    "alternative_phone"=>"555-555-0199",
    "country_id"=>1,
    "country_iso"=>"US",
    "state_id"=>1,
    "state_name"=>nil,
    "state_text"=>"AL",
    "country"=>
  {
      "id"=>1,
      "iso_name"=>"UNITED STATES",
      "iso"=>"US",
      "iso3"=>"USA",
      "name"=>"United States",
      "numcode"=>840
    },
    "state"=>
  {
      "id"=>1,
      "name"=>"Alabama",
      "abbr"=>"AL",
      "country_id"=>1
    }
  },
  "line_items"=>[],
  "payments"=>[],
  "shipments"=>[],
  "adjustments"=>[],
  "permissions"=>{
  },
  "credit_cards"=>[]
}
```

### Failed response

**Response code** 422
```json
{
  "error"=>"You are not authorized to perform that action."
}
```
