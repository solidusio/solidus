# Overview

Easy upgrades are a core goal of Solidus. It should be easy for your production
store to get onto the newest, most performant version of Solidus.

## Straightforward upgrades

Upgrading should not take months of preparation. We aim to make upgrades
straightforward and painless. We use [Semantic Versioning][semver] to avoid
unnecessary breaking changes. See the [Versioning guidelines][versioning]
article for more information.

[semver]: https://semver.org/ 
[versioning]: versioning-guidelines.html

## Extensions should just work

Multiple versions of your Solidus extensions should work across multiple
versions of Solidus. We do not think that you should have to tether your Solidus
version just so you can keep running an extension that provides your store's
flagship feature.

We maintain a number of Solidus extensions with good test coverage. Our [Solidus
extensions list][extensions] also includes a compatibility chart for each major
and minor version of Solidus.

[extensions]: http://extensions.solidus.io

## You can migrate from Spree to Solidus

If you run a store that uses Spree 2.x, you can migrate from Spree to
Solidus with relative ease. See the [Migrate from Spree][migrate-from-spree]
article for more information.

If you have extended your Spree store's models or have made substantial
customizations to Spree, the migration may require some additional preparation.

If you want to talk about your upcoming migration with somebody, [join our Slack
team][slack] and start a conversation about it in the *#support* channel.

[migrate-from-spree]: migrate-from-spree.html
[slack]: http://slack.solidus.io/
