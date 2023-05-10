# frozen_string_literal: true

require_relative '../../../core/lib/spree/core/version'

module Solidus
  # Provides context for the pipeline in which a PR is being submitted.
  #
  # @api private
  class PipelineContext
    MAIN_BRANCH = 'main'

    VERSION_PREFIX = 'v'

    VERSION_SEPARATOR = '.'

    DEV_VERSION_SUFFIX = '.dev'

    STABLE_VERSION_REGEXP = /^#{VERSION_PREFIX}(\d+)#{VERSION_SEPARATOR}(\d+)#{VERSION_SEPARATOR}(\d+)$/.freeze

    attr_reader :tags,
                :base_branch,
                :tracking_major

    def self.tracking_major?
      Spree::VERSION.split('.')[1..2] == ['0', '0']
    end

    def initialize(tags:, base_branch:, last_minor: false, tracking_major: self.class.tracking_major?)
      @tags = tags.select { |tag| tag.match?(STABLE_VERSION_REGEXP) }
      raise ArgumentError, 'tags cannot be empty' unless tags.any?

      @base_branch = base_branch
      @tracking_major = tracking_major
      raise ArgumentError, "branch #{base_branch} cannot track major version" if tracking_major && !main_branch?

      @last_minor = last_minor
      raise ArgumentError, "branch #{base_branch} cannot track a last minor release" if last_minor && !main_branch?
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

    def current_diff_source_tag
      return current_tag unless main_branch?

      current_tag
        .split(VERSION_SEPARATOR)
        .then { |(major, minor, patch)| [major, minor, '0'] }
        .join(VERSION_SEPARATOR)
    end

    def candidate_tag
      @candidate_tag ||= next_tag(current_tag, @tracking_major)
    end

    def candidate_version
      @candidate_version ||= candidate_tag.delete_prefix(VERSION_PREFIX)
    end

    def candidate_minor_version
      @candidate_minor_version ||= candidate_version.split(VERSION_SEPARATOR)[0..1].join(VERSION_SEPARATOR)
    end

    def candidate_patch_branch
      @candidate_patch_branch ||=
        begin
          candidate_tag
            .split(VERSION_SEPARATOR)[0..1]
            .join(VERSION_SEPARATOR)
        end
    end

    def next_candidate_tag
      @next_candidate_tag ||= next_tag(candidate_tag, @last_minor)
    end

    def next_candidate_dev_version
      @next_candidate_dev_version ||= next_candidate_tag.delete_prefix(VERSION_PREFIX) + DEV_VERSION_SUFFIX
    end

    private

    def main_branch?
      base_branch == MAIN_BRANCH
    end

    def next_tag(from, next_is_major)
      from
        .delete_prefix(VERSION_PREFIX)
        .split(VERSION_SEPARATOR)
        .map(&:to_i)
        .then { |version_numbers| bump(version_numbers, next_is_major) }
        .join(VERSION_SEPARATOR)
        .prepend(VERSION_PREFIX)
    end

    def highest_tag_between(tags)
      tags
        .map { |tag| tag.delete_prefix(VERSION_PREFIX) }
        .max_by { |version_number| Gem::Version.new(version_number) }
        .prepend(VERSION_PREFIX)
    end

    def bump(version_numbers, next_is_major)
      main_branch? ? bump_for_main(*version_numbers, next_is_major) : bump_for_patch(*version_numbers)
    end

    def bump_for_main(major, minor, patch, next_is_major)
      next_is_major ? [major + 1, 0, 0] : [major, minor + 1, 0]
    end

    def bump_for_patch(major, minor, patch)
      [major, minor, patch + 1]
    end
  end
end
