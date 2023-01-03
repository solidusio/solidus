# frozen_string_literal: true

require_relative 'release_drafter'
require_relative 'release_drafter/client'

module Solidus
  # @api private
  module ChangelogUpdater
    def self.call(
      github_token:,
      repository:,
      candidate_tag:,
      client: Solidus::ReleaseDrafter::Client.new(github_token: github_token, repository: repository),
      changelog_file_path: File.expand_path('../../../CHANGELOG.md', __dir__),
      now: Time.now
    )
      new_entries = client
        .fetch_draft(tag: candidate_tag)
        .content
        .gsub(ReleaseDrafter::NO_EDIT_WARNING, '')
      old_entries = File.read(changelog_file_path)

      File.write(
        changelog_file_path,
        changelog_template(candidate_tag, now, new_entries, old_entries)
      )
    end

    def self.changelog_template(candidate_tag, now, new_entries, old_entries)
      <<~CHANGELOG.strip
          ## Solidus #{candidate_tag} (#{now.strftime('%Y-%m-%d')})

          #{new_entries}

          #{old_entries}
      CHANGELOG
    end
    private_class_method :changelog_template
  end
end

