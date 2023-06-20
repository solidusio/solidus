---
name: New Minor Release
about: Create a issue for tracking a new minor release.
title: 'Release vX.Y.Z'
labels: enhancement
assignees: ''

---

## It is time for a new minor release for Solidus!

We are committed to release every quarter in order to have a constant and predictable cadence for our deliverables.

For more information, check out our [Release Policy](https://solidus.io/release_policy/) page.

## Detailed list of steps for the release

Here are the steps to follow to release a new minor version.
They are written in the order required to make the process work. However, some material required for the release should be prepared before starting with those steps, like the text of the
upgrade guide or the [messages](https://github.com/solidusio/solidus/wiki/Templates-for-Release-Messages) to send to the community.

### Release preparation

- [ ] Be sure there are no pending PRs that you want to include in the next minor.
- [ ] Run the [Prepare Release Workflow](https://github.com/solidusio/solidus/actions/workflows/prepare_release.yml), leaving `main` as the branch and the checkbox to prepare the next major unchecked (unless necessary).
- [ ] A new auto-generated PR will appear; be sure everything looks good and merge it.

More details about the release workflows are described on our
[Release pipeline automation](https://github.com/solidusio/solidus/wiki/Release-pipeline-automation) wiki page,
which we encourage to review if the assignee is not familiar with the topic.

### Release the Solidus gems on Rubygems

To officially release the Solidus gems, you need to have permissions on RubyGems, with 2FA enabled.

Open Solidus on your local machine and run:

```bash
git checkout main
git pull
gem release
```

You will be prompted to enter your 2FA code multiple times, one for each solidus' subgems.

- [ ] Release on RubyGems done!

### After-release Chores

Now that Solidus has been released, we need to cleanup the `main` branch to get ready for
the next release. As you may have noticed, when the "Release Preparation" PR has been merged,
a new PR has been automatically created. That PR already contains the code to get our repository
clean and ready.

- [ ] Post-Release PR Merged!

### Steps to do outside the main repository

- [ ] [[Guides](https://github.com/solidusio/edgeguides/)] Publish upgrade instruction for the new version ([e.g. PR](https://github.com/solidusio/edgeguides/pull/78)).
- [ ] [[Guides](https://github.com/solidusio/edgeguides/)] Create a [new version with docusaurus](https://docusaurus.io/docs/versioning) of the guides, pointing the main one to the last version released (`npm run docusaurus docs:version X.Y`).
- [ ] [[Starter Frontend](https://github.com/solidusio/solidus_starter_frontend)] Create a new matching branch (e.g. `v3.3`)
- [ ] [[Starter Frontend](https://github.com/solidusio/solidus_starter_frontend)] In the new branch (e.g. `v3.3`), change the [default solidus target branch in the CircleCI Config](https://github.com/solidusio/solidus_starter_frontend/blob/4fd99d229cefbe22e7a3916a6dcb6a0cc6cbd41b/.circleci/config.yml#L96) to point to the newly created branch.
- [ ] [[Starter Frontend](https://github.com/solidusio/solidus_starter_frontend)] Change [Latest Version Nightly build Scheduled Pipeline's trigger](https://app.circleci.com/settings/project/github/solidusio/solidus_starter_frontend/triggers) to point to the newly created branch (e.g. `v3.3`).
- [ ] [[CircleCI Extensions Orb](https://github.com/solidusio/circleci-orbs-extensions)] Change [current](https://github.com/solidusio/circleci-orbs-extensions/blob/53b2fcd42accafce96b1c073713c187e1aaf0b23/src/commands/run-tests-solidus-current.yml) and [older](https://github.com/solidusio/circleci-orbs-extensions/blob/53b2fcd42accafce96b1c073713c187e1aaf0b23/src/commands/run-tests-solidus-older.yml) commands to reflect the new versions status.
- [ ] [[solidus.io](https://github.com/solidusio/solidus-site)] Add the new version in the [versions yml file](https://github.com/solidusio/solidus-site/blob/1a6a7386d7ca85400be31bfe38f903da84844bb2/data/versions.yml).
- [ ] [[solidus.io](https://github.com/solidusio/solidus-site)] Create a new blog post that links to the upgrade instructions on our guides.
- [ ] [[REST API docs](https://solidus.stoplight.io/settings/solidus)] In the Branches section, track the new version's branch and set it as default.
- [ ] [[OpenCollective](https://opencollective.com/solidus)] Create an update for the new release.
- [ ] [[Twitter](https://twitter.com/solidusio)] Post a Tweet on our SolidusIO account.
- [ ] [[GitHub Discussions](https://github.com/solidusio/solidus/discussions)] Create a new Discussion for the new Minor release in the Announcements category (eg. https://github.com/solidusio/solidus/discussions/4161), and add a link to the upgrade instructions on our guides.
- [ ] [[Slack](https://solidusio.slack.com/archives/C03L07BUM)] Notify the community in the #general channel.
- [ ] [[Wiki](https://github.com/solidusio/solidus/wiki)] Add the new version.
- [ ] [[RubyFlow](https://rubyflow.com/)] Post an update to get visibility on RubyWeekly.
