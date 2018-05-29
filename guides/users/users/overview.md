# Overview

You can manage customer accounts and administrator accounts from the **Users**
page of the Solidus admin interface.

You can search and sort users using a few types of information:

- **Email**: Users sign into your store using an identifying email address.
- **Roles**: Users may have different roles (or permissions) depending on how
  much access you want them to have to your store. By default, users can have
  the role `admin` or no role. See [Roles](#roles) for more information.
- **# Orders**: This field lists the number of orders a customer has made since
  their account was created.
- **Total Spent**: This field lists the amount of money that the customer has
  spent on all of their orders.
- **Member Since**: The date that the user's account was created.

## User information

Solidus stores additional information about users. This information relates the
users to other aspects of your store like payments and orders.

The following information is tracked against your users:

- **Addresses**: Customers have at least one address on file. This address can
  be used as the billing and/or shipping address for orders. The addresses
  displayed in the Solidus admin interface are the customer's last used shipping
  and billing addresses.
- **Order History**: A list of orders associated with the current customer. You
  can select each order in the list to view more detailed order information.
- **Items**: A list of items that the customer has purchased, including the
  quantity of each item and a link to the order associated with the purchase.
- **Store Credit**: A list of store credit payments that have been given to the
  current user.

## Roles

Roles let you define what parts of your store users can access. For example, the
Solidus-provided `admin` role allows a user to access any page in the admin.

You may want to create additional roles like `customer_support` that allow users
to only access customer orders, shipments, and returns.

By default, users with no roles can only access pages on the storefront. If
users without a role try to access the Solidus admin, they are greeted with an
access denied page.

Talk to your developers about adding additional roles and the requirements that
you have for those roles. Role permissions cannot be managed from the Solidus
admin interface. Developers can programmatically give or revoke access to
different pages based on a user's role.

## API access

By default, users with a role of `admin` have an API key that can be used to
interface with your store's [API][api]. Your web development team may want
access to the API in order to build out custom features for your store.

### Clear or generate new API keys

If you want to give a user access to the API, and they don't already have an API
key, you can use the **Generate API key** button when you are editing the user's
account information. If they already have a key and need a new key, you can use
the **Regenerate key** button.

<!-- TODO:
  Add screenshot of the edit user screen of the admin.
-->

Similarly, if you want to revoke access to the API for a user, you can use the
**Clear key** button to remove their key.

[api]: https://en.wikipedia.org/wiki/Application_programming_interface

## Passwords

Users require passwords. By default, users needs passwords that are at least six
characters long. Talk to your developers if you want to change Solidus's
password requirements.
