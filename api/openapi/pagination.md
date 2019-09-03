# Pagination

Most endpoints that return a collection are paginated. A paginated response contains metadata about the current page at the root level and the resources in the current page in a child key named after the resource (e.g. `orders`).

You can pass the `page` and `per_page` parameters to set the current page and the desired number of items per page. Note that the default and the maximum number of items per page is decided at the application level.

All pagination metadata is documented in the individual API endpoints, so take a look there if you're unsure what data you can expect.