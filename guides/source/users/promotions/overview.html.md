# Overview

Solidus's promotions system allows you to give discounts to customers. Discounts
can be applied to different amounts that make up the order:

- Discounts can apply to the entire order's cost.
- Discounts can apply to a line item (or a set of line items) on the order.
- Discounts can apply to the shipping charges on the order.

You can create simple or complex promotions based on store and product
information, including information about your customers's previous orders.

Promotions have four essential parts:

1. [The promotion details](#promotion-details). These include basic information
   about the promotion, how it should be applied, and an optional promotion
   code used to redeem the discount.
2. [Activation methods](#activation-methods). You can change the way that
   promotions are activated. For example, some promotions are activated with
   promotion codes while others are activated automatically.
3. [Promotion rules][promotion-rules]. Rules allow you to configure the
   conditions that must be met before a promotion can be applied to an order.
4. [Promotion actions][promotion-actions]. Actions define what should happen
   when the promotion is applied. In most cases, this is free shipping or a
   discount.

## Create a new promotion

While promotions can be much more complicated, you can create a simple promotion
in just a few steps:

1. In the Solidus admin interface, select the **Promotions** item from the main
   menu.
2. Select the **New Promotion** button.
3. Enter a name for the new promotion in the **Name** field.
4. Fill in any optional fields for your new promotion. For more information
   about the available fields, see [Promotion details](#promotion-details).
5. Choose an [activation method](#activation-methods). By default, the activation
   method is set to **Single promotion code** and requires a single **Promotion
   Code** value.
6. Select the **Create** button to save the new promotion.

## Promotion details

When you create a promotion, you can fill in the following information about it:

- **Name**: The name for the promotion. Customers can see this name during
  checkout and on invoices.
- **Description**: An optional description of the promotion.
- **Promotion Category**: The [promotion category](#promotion-categories) for the
  promotion.
- **Usage Limit**: This sets how many times that a promotion can be used. By
  default, promotions have no usage limit.
- **Start** and **End**: This sets the dates that the promotion should start and
  end by. By default, promotions are active as soon as they are created, and
  they have no end date.

## Activation methods

When you create a new promotion, you can choose from a number of activation
methods:

- **Apply to all orders**: No promotion code is required. If an order meets all
  of the promotion rules, then the promotion is activated.
- **Single promotion code**: The promotion is activated if the customer enters
  the associated promotion code *and* they meet all of the configured [promotion
  rules][promotion-rules].
- **Multiple promotion codes**: The promotion is activated if the customer
  enters one of the many associated promotion codes *and* they meet all of the
  configured promotion rules. See [Multiple promotion
  codes](#multiple-promotion-codes) below for more information.

[promotion-rules]: promotion-rules.html

### Multiple promotions codes

When you create a new promotion that uses the **Multiple promotion codes**
activation method, a number of new configuration fields become available:

- **Base code**: The base promotion code that is used to generate all of the
  promotion codes.
- **Number of codes**: The number of promotion codes that are generated for the
  promotion. Each generated code uses random numbers and letters. For example:
  `x32nr`.
- **Join characters**: The characters that appear between the base code and the
  randomly generated code. For example, you could set a join character of `-` to
  create codes like `code-x32nr`. This field is optional.
- **Per Code Usage Limit**: This sets the amount of times that each generated
  code can be used. By default, there is no usage limit. This field is optional.

#### Download promotion code list

If your promotion uses multiple promotion codes you can download a list of the
codes that were generated for it:

1. Go to the **Promotions** page of the Solidus admin.
2. Select the **Edit** button next to the promotion that you want to download
   promotion codes for.dd
3. Select the **Download Code List** button to download a list of codes in CSV
   format.

<!-- TODO:
  Add screenshot of the Download Code List button being highlighted.
-->

If you have generated multiple batches of codes, you can use the **Promotion
Code Batches** button to view a list of batches, then use the **Download Code
List** link next to the batch you want the codes for.

<!-- TODO:
  Add screenshot of the batch codes list interface.
-->

## Promotion categories

You can set up promotion categories to organize your promotions. Promotion
categories have a **Name** and a **Code**. Your customers cannot see promotion
categories. Only store administrators can see promotion categories.
