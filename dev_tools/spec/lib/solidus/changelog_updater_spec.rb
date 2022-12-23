# frozen_string_literal: true

require 'solidus/changelog_updater'
require 'solidus/release_drafter/draft'
require 'tempfile'

RSpec.describe Solidus::ChangelogUpdater do
  describe '.call' do
    around do |example|
      Tempfile.create('CHANGELOG.md') do |changelog_file|
        example.metadata[:changelog_file] = changelog_file

        example.run
      end
    end

    let(:client) do
      Class.new do
        def fetch_draft(tag:)
          Solidus::ReleaseDrafter::Draft.new(
            url: 'some-url',
            content: <<~MARKDOWN.strip
              <!-- Please, don't edit manually. The content is automatically generated. -->
              NEW CHANGELOG ENTRIES
            MARKDOWN
          )
        end
      end.new
    end

    it 'prepends the Changelog file with content from the current release draft' do |e|
      changelog_file = e.metadata[:changelog_file]
      changelog_file.write <<~MARKDOWN
        PAST CHANGELOG ENTRIES
      MARKDOWN
      changelog_file.rewind

      described_class.(
        candidate_tag: 'v4.0.0',
        changelog_file_path: changelog_file.path,
        repository: 'fake/solidus',
        github_token: 'secret',
        client: client,
        now: Time.new(2023, 1, 1)
      )

      expect(changelog_file.read).to eq <<~MARKDOWN.strip
        ## Solidus v4.0.0 (2023-01-01)

        NEW CHANGELOG ENTRIES

        PAST CHANGELOG ENTRIES
      MARKDOWN
    end
  end
end
