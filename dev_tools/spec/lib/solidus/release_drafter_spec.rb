# frozen_string_literal: true

require 'ostruct'
require 'solidus/release_drafter'

RSpec.describe Solidus::ReleaseDrafter do
  describe '#call' do
    let(:client) do
      Class.new do
        def initialize(prs: {})
          @prs = prs
        end

        def fetch_draft(tag:)
          Solidus::ReleaseDrafter::Draft.empty
        end

        def fetch_pr(pr_number:)
          @prs[pr_number]
        end

        def create_draft(draft:, tag:, branch:)
          draft
        end

        def update_draft(draft:, tag:, branch:)
          draft
        end

        def add_pr(pr_number:, labels: [])
          @prs[pr_number] = OpenStruct.new(
            number: pr_number,
            title: "PR number #{pr_number}",
            labels: labels.map { |name| OpenStruct.new(name: name) },
            user: OpenStruct.new(login: 'alice')
          )
        end
      end.new
    end

    subject do
      described_class.new(
        client: client,
        github_token: 'dummy',
        repository: 'fake/solidus'
      )
    end

    it 'adds the PR under a single matching label' do
      client.add_pr(pr_number: 1, labels: ['changelog:solidus_core'])

      expect(
        subject.call(pr_number: 1, current_diff_source_tag: 'v3.0.0', candidate_tag: 'v3.1.0', branch: 'master').content
      ).to match(/#{Regexp.escape("## Solidus Core\n- PR number 1 #1 (@alice)")}/)
    end

    it 'adds the PR under more than one matching label' do
      client.add_pr(pr_number: 1, labels: %w[changelog:solidus_core changelog:solidus_api])

      expect(
        subject.call(pr_number: 1, current_diff_source_tag: 'v3.0.0', candidate_tag: 'v3.1.0', branch: 'master').content
      ).to match(/#{Regexp.escape("## Solidus Core\n- PR number 1 #1 (@alice)")}.*#{Regexp.escape("## Solidus API\n- PR number 1 #1 (@alice)")}/m)
    end

    it 'ignores if no matching label is present' do
      client.add_pr(pr_number: 1, labels: %w[other])

      expect(
        subject.call(pr_number: 1, current_diff_source_tag: 'v3.0.0', candidate_tag: 'v3.1.0', branch: 'master')
      ).to be(nil)
    end

    it 'ignores if the skipping label is present' do
      client.add_pr(pr_number: 1, labels: %w[changelog:solidus_core changelog:skip])

      expect(
        subject.call(pr_number: 1, current_diff_source_tag: 'v3.0.0', candidate_tag: 'v3.1.0', branch: 'master')
      ).to be(nil)
    end

    it 'adds a non-edit warning' do
      client.add_pr(pr_number: 1, labels: %w[changelog:solidus_core changelog:solidus_api])

      expect(
        subject.call(pr_number: 1, current_diff_source_tag: 'v3.0.0', candidate_tag: 'v3.1.0', branch: 'master').content
      ).to include("don't edit manually")
    end

    it 'adds a link to the full Changelog' do
      client.add_pr(pr_number: 1, labels: %w[changelog:solidus_core changelog:solidus_api])

      expect(
        subject.call(pr_number: 1, current_diff_source_tag: 'v3.0.0', candidate_tag: 'v3.1.0', branch: 'master').content
      ).to include("**Full Changelog**: https://github.com/fake/solidus/compare/v3.0.0...v3.1.0")
    end
  end
end
