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

## Spree 2.2.2 (May 15, 2014) ##
