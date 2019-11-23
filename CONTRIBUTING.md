## Read our community guidelines

Before you contribute, please take a look at the [Community Guidelines](https://solidus.io/community-guidelines/).

Thanks for your interest in contributing to the Solidus project!

## Filing an issue

When filing an issue on the Solidus project, please provide these details:

* A comprehensive list of steps to reproduce the issue
* What you're *expecting* to happen compared with what's *actually* happening
* Your application's complete `Gemfile`, and `Gemfile.lock` as text in a [Gist](https://gist.github.com) (*not as an image*)
* Any relevant stack traces ("Full trace" preferred)

In 99% of cases, this information is enough to determine the cause and solution
to the problem that is being described.

Please remember to format code using triple backticks (\`) so that it is neatly
formatted when the issue is posted.

Any issue that is open for 14 days without actionable information or activity
will be marked as "stalled" and then closed. Stalled issues can be re-opened if
the information requested is provided.

## Opening pull requests

We gladly accept pull requests to add documentation, fix bugs and, in some circumstances,
add new features to Solidus.

Here's a quick guide to opening a PR:

1. Fork the repo.

2. Run the tests. We only take pull requests with passing tests, and it's great
to know that you have a clean slate:

        $ bin/build

3. Create new branch then make changes and add tests for your changes. Only
refactoring and documentation changes require no new tests. If you are adding
functionality or fixing a bug, we need tests!

4. Push to your fork and submit a pull request. If the changes will apply cleanly
to the latest stable branches and master branch, you will only need to submit one
pull request.

5. If a PR does not apply cleanly to all of its targeted branches - for example,
slighty different fixes for mulitple versions -  then multiple PRs are necessary.

At this point you're waiting on us. We like to at least comment on, if not
accept, pull requests within three business days (and, typically, one business
day). We may suggest some changes or improvements or alternatives.

Typically, Pull Requests can be merged when they have met the following criteria:

- Open for at least 24 hours
- Passing CI
- 2 or more Core Team approvals

Though in some cases the Core Team may choose not to merge a PR that meets these requirements.

### Pull Request guidelines

* The specs must pass for each individual commit
* Each individual commit should make sense by itself as far as possible
* Breaking up a large change into smaller (coherent) commits is encouraged
* We do not currently have a policy about whether or not to force-push while
people are reviewing your pull request
* Good commit messages are also encouraged. Here are some resources on writing
good commit messages:
  * [Notes from Linus](https://github.com/torvalds/subsurface/commit/b6590150d68df528efd40c889ba6eea476b39873)
  * [Erlang's guide](https://github.com/erlang/otp/wiki/Writing-good-commit-messages)
  * [An often-cited post](http://tbaggery.com/2008/04/19/a-note-about-git-commit-messages.html)

Some things that will increase the chance that your pull request is accepted,
taken straight from the [Ruby on Rails guide](http://guides.rubyonrails.org/contributing_to_ruby_on_rails.html):

* Use Rails idioms and helpers
* Include tests that fail without your code, and pass with it
* Update the documentation, the surrounding one, examples elsewhere, guides,
  whatever is affected by your contribution

### Follow the coding conventions

This is a Rails-based framework.  See the [Rails coding conventions](http://guides.rubyonrails.org/contributing_to_ruby_on_rails.html#follow-the-coding-conventions).

And in case we didn't emphasize it enough: we love tests!
