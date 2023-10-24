# frozen_string_literal: true

require 'bundler/setup'
require 'octokit'
require 'faraday'

ROOT = File.expand_path('../..', __dir__)
OCTOKIT = Octokit::Client.new(access_token: ENV.fetch('GITHUB_TOKEN')).tap { _1.auto_paginate = true }
