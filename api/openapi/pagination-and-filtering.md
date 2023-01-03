# Pagination and Filtering

## Pagination

Most endpoints that return a collection are paginated. A paginated response contains metadata about the current page at the root level and the resources in the current page in a child key named after the resource (e.g. `orders`).

You can pass the `page` and `per_page` parameters to set the current page and the desired number of items per page. Note that the default and the maximum number of items per page is decided at the application level.

All pagination metadata is documented in the individual API endpoints, so take a look there if you're unsure what data you can expect.

## Filtering

Most endpoints that return a collection also have the ability to filter data using query params. This works taking advantage of the search filters provided by [Ransack](https://github.com/activerecord-hackery/ransack/).

For example, if we want to retrieve only products that contain the word "Watch" in their title we can make the following request:

```
GET /products?q[name_cont]=Watch
```

The `name_cont` matcher will generate a query using `LIKE` to retrieve all the products that contain the value specified. For an extensive list of search matchers supported, please refer to the Ransack documentation.

The result will be paginated as described in the paragraph above.

