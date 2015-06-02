## Solidus 1.0

*   Replace ShipmentMailer with CartonMailer

    IMPORTANT: Appliction and extension code targeting ShipmentMailer needs to
    be updated to target CartonMailer instead.

    Issue https://github.com/bonobos/spree/pull/299

*   Add Carton concept to Spree

    Cartons represent containers of inventory units that have been shipped. See
    carton.rb for details.

*   Remove Promotion::Actions::CreateLineItems

    They were broken in a couple ways.

    Issue https://github.com/bonobos/spree/pull/259

    *Phillip Birtcher* *Jordan Brough*

*   Remove Api::CheckoutsController

    Issue https://github.com/bonobos/spree/pull/229

    *Jordan Brough*

*   Remove the Spree::Alert system

    Issue https://github.com/bonobos/spree/pull/222

    *Jordan Brough*

*   Remove Spree::Money preferences

    Removes Spree::Config's `symbol_position`, `no_cents`, `decimal_mark`, and
    `thousands_separator`. This allows us to use the better defaults provided
    by RubyMoney. For the same functionality of the existing preferences,
    `Spree::Money.default_formatting_rules` can be used.

    https://github.com/solidusio/solidus/pull/47

    *John Hawthorn*

*   Remove SSL preferences and controller helpers

    In production any ecommerce site should use SSL for all connections. It is
    both a security necessity and an SEO gain. Instead of the existing
    configuration, SSL should be configured by the web server, load balancer,
    or through rails.

    For information on configuring rails for SSL see
    http://api.rubyonrails.org/classes/ActionController/ForceSSL/ClassMethods.html

    *Clarke Brunsdon*
