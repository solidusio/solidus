# frozen_string_literal: true

require_relative '../../../core/lib/spree/core/version'

module Solidus
  # Provides context for the pipeline in which a PR is being submitted.
  #
  # @api private
  class PipelineContext
    MAIN_BRANCH = 'master'

    VERSION_PREFIX = 'v'

    VERSION_SEPARATOR = '.'

    STABLE_VERSION_REGEXP = /^#{VERSION_PREFIX}(\d+)#{VERSION_SEPARATOR}(\d+)#{VERSION_SEPARATOR}(\d+)$/.freeze

    attr_reader :tags,
                :base_branch,
                :tracking_major

    def self.tracking_major?
      Spree::VERSION.split('.')[1..2] == ['0', '0']
    end

    def initialize(tags:, base_branch:, tracking_major: self.class.tracking_major?)
      @tags = tags.select { |tag| tag.match?(STABLE_VERSION_REGEXP) }
      raise ArgumentError, 'tags cannot be empty' unless tags.any?

      @base_branch = base_branch
      @tracking_major = tracking_major
      raise ArgumentError, "branch #{base_branch} cannot track major version" if tracking_major && !main_branch?
    end

    def current_tag
      @current_tag ||=
        begin
          if main_branch?
            highest_tag_between(tags)
          else
            highest_tag_between(tags.select { |tag| tag.start_with?(base_branch) })
          end
        end
    end

    def candidate_tag
      @candidate_tag ||=
        begin
          current_tag
            .delete_prefix(VERSION_PREFIX)
            .split(VERSION_SEPARATOR)
            .map(&:to_i)
            .then { |version_numbers| bump(version_numbers) }
            .join(VERSION_SEPARATOR)
            .prepend(VERSION_PREFIX)
        end
    end

    private

    def main_branch?
      base_branch == MAIN_BRANCH
    end

    def highest_tag_between(tags)
      tags
        .map { |tag| tag.delete_prefix(VERSION_PREFIX) }
        .max_by { |version_number| Gem::Version.new(version_number) }
        .prepend(VERSION_PREFIX)
    end

    def bump(version_numbers)
      main_branch? ? bump_for_main(*version_numbers) : bump_for_patch(*version_numbers)
    end

    def bump_for_main(major, minor, patch)
      tracking_major ? [major + 1, 0, 0] : [major, minor + 1, 0]
    end

    def bump_for_patch(major, minor, patch)
      [major, minor, patch + 1]
    end
  end
end
