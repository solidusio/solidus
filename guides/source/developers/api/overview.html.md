# Overview

Solidus's REST API (the [`solidus_api` gem][api-gem]) is designed to let you
access data contained within your store.

The API uses a standard read/write interface that returns JSON. This means that
you can easily create third-party applications that can consume your Solidus
store data. The API is implemented using controllers and [Jbuilder][jbuilder]
views.

It is also possible to build more sophisticated middleware applications that
bridge between your store and a warehouse or inventory system.

[api-gem]: https://github.com/solidusio/solidus/tree/master/api
[jbuilder]: https://github.com/rails/jbuilder

## Make an API call

By default, you can make API calls if you are an authenticated user with the
role of `admin`.

### Requests

To make a request to the API, set a Bearer Authentication header with the Spree API key:

```bash
curl --header "Authorization: Bearer <key>" http://yourstore.com/api/products/1
```

Note that for Solidus versions 2.7 and below a custom `X-Spree-Token: <key>` header is used.   

Alternatively, you can pass through the token as a URL parameter if you are
unable to pass it through a header:

```bash
curl http://example.com/api/products/1?token=<key>
```

The `token` parameter allows the request to assume the same level of permissions
as the actual user to whom the token belongs.

### Authentication

Any user with a `Spree::Role` of `admin` has an API key generated for them when
their account is created.You can get the key value from the user table's
`spree_api_key` column.

For example, if you use the `Spree::User` model provided by the
[`solidus_auth_devise` gem][solidus-auth-devise], you can access the user's API
key in your Rails console with a command like this:

```ruby
Spree::User.find(1).spree_api_key
```

Store administrators can view or regenerate API keys from the `solidus_backend`
interface from the **Users** page by editing a user with the admin role.

[solidus-auth-devise]: https://github.com/solidusio/solidus_auth_devise

## Endpoint rules

The Solidus API endpoints comply with the following rules:

- Successful `GET` requests always return a status of `200`.
- Successful `CREATE` and `UPDATE` requests result a status of `201` and
  `200`.
- Successful `DELETE` requests return a status of `204` and no content.
- Unauthorized requests return a status of `401` and no content.
- When a resource cannot be found, the API returns a status of `404`.
- Failed `CREATE` and `UPDATE` requests return a status of `422` with a hash
  containing an `error` key and an `errors` key. The `errors` value contains all
  of the ActiveRecord validation errors encountered when saving the record.
- Requests that list collections (like an `/api/products` request) are paginated
  and display 25 records per page by default.

## Custom responses

You can customize the responses from the API in two ways:

1. Override a view from the `solidus_api` gem.
2. Provide a new view with your custom template in your application.

For example, if you wanted to override the default
[`products/show.json.jbuilder`][products-show-template] template, you could
place a file with the same path and file name in your application. In this case,
your custom template should be created at the path
`app/views/spree/api/products/show.json.jbuilder`.

[products-show-template]: https://github.com/solidusio/solidus/blob/master/api/app/views/spree/api/products/show.json.jbuilder
