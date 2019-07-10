# Checkout flow

Given the amount of endpoints at your disposal, it can be difficult to understand how to string the right API calls together to perform a full checkout flow. This document explains how to perform a full checkout flow.

## 1. Create an order

The first step is to create an order via `POST /orders`. You should save the number of the order that is created as well as the guest token, in case you are not authenticating with an API key.

## 2. Fill the cart

Once you have an order, you can begin filling your cart. Here are some endpoints you can use for that:

- `POST /checkouts/:order_number/line_items`
- `PATCH /checkouts/:order_number/line_items/:id`
- `DELETE /checkouts/:order_number/line_items/:id`
- `PUT /orders/:order_number/empty`

## 3. (Optional) Apply a coupon code

You can also apply a coupon code on the order via `POST /orders/:order_number/coupon_codes`.

## 4. Start the checkout flow

When you are ready to start the checkout flow, you can call `PUT /checkouts/:order_number/next` to transition the order from the `cart` to the `address` state.

## 5. Enter billing and shipping addresses

To enter the billing and shipping addresses, use the `PATCH /checkouts/:order_number` endpoint.

Once again, call `PUT /checkouts/:order_number/next` to transition the order from the `address` to the `shipping` state.

## 6. Select a shipping method

You can retrieve the available shipping methods, along with their rates, via `GET /shipments/:shipment_number/estimated_rates`. This allows you to let your user choose the shipping method they prefer.

When you want to select a shipping method, call `PUT /shipments/:shipment_number/select_shipping_method`.

Finally, call `PUT /checkouts/:order_number/next` to transition the order from the `shipping` to the `payment` state.

## 7. Enter payment details

To create a payment, call `POST /orders/:order_number/payments`.

Now call `PUT /checkouts/:order_number/next` to transition the order from the `payment` to the `confirm` state.

## 8. Complete the order

At this point, you should show the user a summary of their cart and ask them to confirm they want to place the order.

When they confirm, call `PUT /checkouts/:order_number/complete` to complete the checkout flow and place the order!
