# frozen_string_literal: true

template =
  ENV["SOLIDUS_STARTER_FRONTEND_TEMPLATE"] ||
  begin
    version = Spree.solidus_version if defined?(Spree) && Spree.respond_to?(:solidus_version)
    gem_version = version ? Gem::Version.new(version) : nil

    ref =
      if gem_version && !gem_version.prerelease?
        "v#{gem_version.segments[0, 2].join('.')}"
      else
        "main"
      end

    "https://github.com/solidusio/solidus/raw/#{ref}/starter_frontend/template.rb"
  end

apply template
