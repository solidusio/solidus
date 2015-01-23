# Contributing

Spree i18n is an open source project and we encourage contributions. Please see the [contributors guidelines](http://spreecommerce.com/documentation/contributing_to_spree.html) for more information before contributing.

In the spirit of [free software][1], **everyone** is encouraged to help improve this project.

Here are some ways *you* can contribute:

* by using prerelease versions
* by reporting [bugs][2]
* by suggesting new features
* by writing [translations][3] (e.g. use branch 2-4-stable for Spree v2.4.x)
* by writing or editing documentation
* by writing specifications
* by writing code (*no patch is too small*: fix typos, add comments, clean up inconsistent whitespace)
* by refactoring code
* by resolving [issues][2]
* by reviewing patches

---

## Filing an issue

When filing an issue on this extension, please first do these things:

* Verify you can reproduce this issue in a brand new application.
* Run through the steps to reproduce the issue again.

In the issue itself please provide:

* A comprehensive list of steps to reproduce the issue.
* What you're *expecting* to happen compared with what's *actually* happening.
* The version of Spree *and* the version of Rails.
* A list of all extensions.
* Any relevant stack traces ("Full trace" preferred)
* Your `Gemfile`

In 99% of cases, this information is enough to determine the cause and solution to the problem that is being described.

---

## Pull requests

We gladly accept pull requests to fix bugs and, in some circumstances, add new features to this extension.

Here's a quick guide:

1. Fork the repo.

2. Run the tests. We only take pull requests with passing tests, and it's great to know that you have a clean slate.

3. Create new branch then make changes and add tests for your changes. Only refactoring and documentation changes require no new tests. If you are adding functionality or fixing a bug, we need tests!

4. Push to your fork and submit a pull request. If the changes will apply cleanly to the latest stable branches and master branch, you will only need to submit one pull request.

At this point you're waiting on us. We may suggest some changes or improvements or alternatives.

Some things that will increase the chance that your pull request is accepted, taken straight from the Ruby on Rails guide:

* Use Rails idioms and helpers.
* Include tests that fail without your code, and pass with it.
* Update the documentation, the surrounding one, examples elsewhere, guides, whatever is affected by your contribution.

---

## TL;DR

* Fork the repo
* Clone your repo
* Run `bundle install`
* Run `bundle exec rake test_app` to create the test application in `spec/dummy`
* Make your changes
* Ensure specs pass by running `bundle exec rspec spec`
* Ensure all syntax ok by running `rubocop .`
* Submit your pull request

And in case we didn't emphasize it enough: **we love tests!**

[1]: http://www.fsf.org/licensing/essays/free-sw.html
[2]: https://github.com/spree-contrib/spree_i18n/issues
[3]: https://github.com/spree-contrib/spree_i18n/tree/master/config/locales
