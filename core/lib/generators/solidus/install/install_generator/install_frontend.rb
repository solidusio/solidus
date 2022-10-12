# frozen_string_literal: true

module Solidus
  class InstallGenerator < Rails::Generators::Base
    class InstallFrontend
      attr_reader :bundler_context,
                  :generator_context

      def initialize(bundler_context:, generator_context:)
        @bundler_context = bundler_context
        @generator_context = generator_context
      end

      def call(frontend, installer_adds_auth:)
        case frontend
        when 'solidus_frontend'
          install_solidus_frontend
        when 'solidus_starter_frontend'
          install_solidus_starter_frontend(installer_adds_auth)
        end
      end

      private

      def install_solidus_frontend
        unless @bundler_context.component_in_gemfile?(:frontend)
          BundlerContext.bundle_cleanly do
            `bundle add solidus_frontend`
            `bundle install`
          end
        end

        # Solidus bolt will be handled in the installer as a payment method.
        begin
          skip_solidus_bolt = ENV['SKIP_SOLIDUS_BOLT']
          ENV['SKIP_SOLIDUS_BOLT'] = 'true'
          @generator_context.generate("solidus_frontend:install #{@generator_context.options[:auto_accept] ? '--auto-accept' : ''}")
        ensure
          ENV['SKIP_SOLIDUS_BOLT'] = skip_solidus_bolt
        end
      end

      def install_solidus_starter_frontend(installer_adds_auth)
        @bundler_context.remove(['solidus_frontend']) if @bundler_context.component_in_gemfile?(:frontend)

        # TODO: Move installation of solidus_auth_devise to the
        # solidus_starter_frontend template
        unless auth_present?(installer_adds_auth)
          BundlerContext.bundle_cleanly { `bundle add solidus_auth_devise` }
          @generator_context.generate('solidus:auth:install --auto-run-migrations')
        end
        `LOCATION="https://raw.githubusercontent.com/solidusio/solidus_starter_frontend/main/template.rb" bin/rails app:template`
      end

      def auth_present?(installer_adds_auth)
        installer_adds_auth || @bundler_context.component_in_gemfile?(:auth_devise)
      end
    end
  end
end
