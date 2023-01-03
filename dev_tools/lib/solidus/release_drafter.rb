# frozen_string_literal: true

require_relative 'release_drafter/client'
require_relative 'release_drafter/builder'

module Solidus
  # Coordinates updating the release draft on GitHub when a PR is merged.
  #
  # @api private
  class ReleaseDrafter
    LABEL_PREFIX = 'changelog:'

    LABELS = {
      "#{LABEL_PREFIX}solidus_core" => 'Solidus Core',
      "#{LABEL_PREFIX}solidus_backend" => 'Solidus Backend',
      "#{LABEL_PREFIX}solidus_api" => 'Solidus API',
      "#{LABEL_PREFIX}solidus_sample" => 'Solidus Sample',
      "#{LABEL_PREFIX}solidus" => 'Solidus'
    }.freeze

    SKIP_LABEL = "#{LABEL_PREFIX}skip"

    NO_EDIT_WARNING = <<~TXT
      <!-- Please, don't edit manually. The content is automatically generated. -->
    TXT

    def initialize(github_token:, repository:,
                   client: Client.new(github_token: github_token, repository: repository))
      @repository = repository
      @client = client
    end

    def call(pr_number:, current_diff_source_tag:, candidate_tag:, branch:)
      pr = @client.fetch_pr(pr_number: pr_number)
      pr_labels = pr.labels.map(&:name)
      matching_labels = LABELS.keys & pr_labels
      return if pr_labels.include?(SKIP_LABEL) || matching_labels.empty?

      draft = @client.fetch_draft(tag: candidate_tag)
      Builder.new(draft: draft, categories: LABELS.values, prepend: NO_EDIT_WARNING, append: full_changelog(current_diff_source_tag, candidate_tag))
        .then { |builder| add_pr(builder, pr, matching_labels) }
        .then { |draft| save_release(draft, candidate_tag, branch) }
    end

    private

    def builder(draft, current_diff_source_tag, candidate_tag)
      Builder.new(draft: draft, categories: LABELS.values, prepend: NO_EDIT_WARNING, append: full_changelog(current_diff_source_tag, candidate_tag))
    end

    def add_pr(builder, pr, labels)
      builder.add(
        number: pr.number,
        categories: LABELS.values_at(*labels),
        title: pr.title,
        user: pr.user.login
      )
    end

    def save_release(draft, candidate_tag, branch)
      if draft.new?
        @client.create_draft(draft: draft, tag: candidate_tag, branch: branch)
      else
        @client.update_draft(draft: draft, tag: candidate_tag, branch: branch)
      end
    end

    def full_changelog(current_diff_source_tag, candidate_tag)
      <<~TXT

        **Full Changelog**: https://github.com/#{@repository}/compare/#{current_diff_source_tag}...#{candidate_tag}
      TXT
    end
  end
end

