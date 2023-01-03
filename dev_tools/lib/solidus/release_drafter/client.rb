# frozen_string_literal: true

require 'octokit'
require 'faraday'
require_relative 'draft'

module Solidus
  class ReleaseDrafter
    # Octokit wrapper for the network calls we need to work with GH releases.
    #
    # @api private
    class Client
      def initialize(github_token:, repository:)
        @repository = repository
        @client = Octokit::Client.new(access_token: github_token).tap { |c| c.auto_paginate = true }
      end

      def fetch_draft(tag:)
        release = @client.releases(@repository).find do |release|
          release.name == tag
        end
        release ? Draft.new(url: release.url, content: release.body) : Draft.empty
      end

      def fetch_pr(pr_number:)
        @client.pull(@repository, pr_number)
      end

      def create_draft(draft:, tag:, branch:)
        @client.create_release(
          @repository,
          tag,
          name: tag,
          target_commitish: branch,
          body: draft.content,
          draft: true
        ) && draft
      end

      def update_draft(draft:, tag:, branch:)
        @client.update_release(
          draft.url,
          name: tag,
          body: draft.content,
          draft: true,
          tag_name: tag,
          target_commitish: branch
        ) && draft
      end

      def publish_draft(tag:)
        fetch_draft(tag: tag)
          .then { |draft| @client.update_release(draft.url, draft: false) }
      end
    end
  end
end

