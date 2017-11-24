# Overview

Solidus has a highly flexible payments model which allows multiple payment
methods to be available during checkout. The logic for processing payments is
decoupled from orders, making it easy to define custom payment methods with
their own processing logic.

Payment methods typically represent a payment processor. Payment methods will
process credit card payments, and may also include non credit card payment
methods such as Check or StoreCredit, which are provided in Solidus by default.

The `Payment` model in Solidus tracks payments against Orders.
Payments relate to a `source` which indicates how the payment was made, and a
`PaymentMethod`, indicating the processor used for this payment.

When a payment is created, it is given a unique, 8-character identifier. This
is used when sending the payment details to the payment processor. Without this
identifier, some payment gateways mistakenly reported duplicate payments.

An explanation of the different states:

* `checkout`: Checkout has not been completed
* `processing`: The payment is being processed (temporary – intended to prevent double submission)
* `pending`: The payment has been processed but is not yet complete (ex. authorized but not captured)
* `failed`: The payment was rejected (ex. credit card was declined)
* `void`: The payment should not be counted against the order
* `completed`: The payment is completed. Only payments in this state count against the order total

The state transition for these is handled by the processing code within Solidus;
however, you are able to call the event methods yourself to reach these states.
The event methods are:

* `started_processing`
* `failure`
* `pend`
* `complete`
* `void`
* `invalidate`
