# frozen_string_literal: true

require 'bundler/setup'
require 'octokit'
require 'faraday'

ROOT = File.expand_path('../..', __dir__)
OCTOKIT = Octokit::Client.new(access_token: ENV.fetch('GITHUB_TOKEN')).tap { _1.auto_paginate = true }

class SolidusVersion < Gem::Version
  def self.correct_tag?(tag)
    tag.start_with?('v') && correct?(tag.delete_prefix('v'))
  end

  def self.latest(branch: 'main', tags: nil)
    tags ||= OCTOKIT.refs('solidusio/solidus', 'tag').map { _1.ref.delete_prefix('refs/tags/') }

    # For maintenance branches we only want to consider tags that are part of the same minor version
    tags.select! { |tag| tag.start_with?("#{branch}.") } if branch != 'main'

    # Take the tag with the highest version number
    tags.grep(/^v/).map { |tag| SolidusVersion.new(tag.delete_prefix('v')) }.max
  end

  def major?
    segments[1..2] == ['0', '0']
  end

  def tag = "v#{self}"
  def branch = "v#{major}.#{minor}"
  def dev = self.class.new("#{self}.dev")
  def major = segments[0]
  def minor = segments[1]
  def patch = segments[2]

  def update(major: nil, minor: nil, patch: nil)
    major ||= segments[0]
    minor ||= segments[1]
    patch ||= segments[2]
    self.class.new([major, minor, patch].join('.'))
  end

  def bump(level)
    case level
    when :major
      update(major: major.next, minor: 0, patch: 0)
    when :minor
      update(minor: minor.next, patch: 0)
    when :patch
      update(patch: patch.next)
    else
      raise ArgumentError, "Unknown bump level: #{level}"
    end
  end
end
