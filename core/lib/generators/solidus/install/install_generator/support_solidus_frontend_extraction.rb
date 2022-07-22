# frozen_string_literal: true

module Solidus
  class InstallGenerator < Rails::Generators::Base
    # Helper for extracting solidus_frontend from solidus meta-gem
    #
    # We're recommending users use newer solidus_starter_frontend. However,
    # we're still shipping solidus_frontend as part of the solidus meta-gem. The
    # reason is that we don't want users updating previous versions to see its
    # storefront gone suddenly.
    #
    # In future solidus releases, solidus_frontend won't be a component anymore.
    # However, until that happens:
    #
    # - For users of the new frontend, we need to prevent pulling
    # solidus_frontend.
    # - For users of the legacy frontend, we need to prevent Bundler from
    # resolving it from the mono-repo while it's still there.
    #
    # This class is a needed companion during the deprecation
    # path. It'll modify the user's Gemfile, breaking the solidus gem down into
    # its components but solidus_frontend.
    class SupportSolidusFrontendExtraction
      attr_reader :bundler_context

      def initialize(bundler_context:)
        @bundler_context = bundler_context
      end

      def call
        return unless needs_to_break_down_solidus_meta_gem?

        break_down_solidus_meta_gem
      end

      private

      def break_down_solidus_meta_gem
        @bundler_context.break_down_components(%w[core backend api sample])
        @bundler_context.remove(['solidus'])
      end

      def needs_to_break_down_solidus_meta_gem?
        @bundler_context.solidus_in_gemfile?
      end
    end
  end
end
