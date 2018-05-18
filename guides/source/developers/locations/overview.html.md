# Overview

In order to sell products, your store requires that you have locations set up.
In Solidus, locations are split up into states, countries, and zones.

| Group     | Contain               |
|-----------|-----------------------|
| States    |                       |
| Countries | States                | 
| Zones     | Countries _or_ states |

Both states and countries refer back to the territorial borders you would find
on a map. (For example, the United States contains 50 states and 16 territories;
Canada contains 10 provinces and 3 territories.)

Zones are more flexible. They can be set up in whatever way serves your store's
business needs.

## Locations affect shipments and taxation 

Locations are required because they affect how orders are taxed and how shipping
is calculated.

For example, if your store is located in Arizona, United States, an order from
within Arizona state would be taxed and shipped differently than an order being
shipped to Tokyo, Japan.

## Zones are your own unique groups of regions

Zones are used to make logical groups of countries or states that are unique to
your store. Zones allow you to set specific around how shipments and taxes are
handled for customers in specific regions. These rules can be as general or
specific as you need. For example, a country or a state could be included in
multiple zones, or none at all. 

Whenever you create a tax rate or a new shipping method, it must be tied to at
least one zone. For a deeper discussion of zones [see the Zones
article](zones.html).

