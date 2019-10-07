# Authentication

The Solidus API provides two means of authentication: one is through your Solidus user's API key, while the other is through an order's guest token.

### API key

You can use your API key to access all resources in the API. The API key must be passed in the `Authorization` header in the following form:

```
Authorization: Bearer API_KEY
```

As an admin, you can find your API token in the admin section under Users > Your e-email > API Access (at `admin/users/<user_id>/edit`)

Example:

```
curl --header "Authorization: Bearer 1a6a9936ad150a2ee345c65331da7a3ccc2de" http://www.my-solidus-site.com/api/stores
```

By default, API keys are only generated for admins, but you can easily customize Solidus to generate them for all users, which is useful for instance if you want users to be able to sign in and manage their profile via the API.

### Order token

For allowing guests to manage their cart and place their order, you can use the order's guest token. This token is contained in the `guest_token` property of the order, and it allows you to perform certain checkout-related operations on the order such as managing line items, completing the checkout flow etc.

The order token must be passed in the `X-Spree-Order-Token` header in the following form:

```
X-Spree-Order-Token: ORDER_TOKEN
```

If you are already providing an API key, you don't need to also provide the order token (although you may do so).
