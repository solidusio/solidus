# frozen_string_literal: true

module Spree
  module Core
    module ControllerHelpers
      module Timezone
        extend ActiveSupport::Concern

        included do
          around_action :set_timezone
        end

        private

        # Sets the timezone for the current request.
        #
        # Uses the most preferred timezone or falls back to the server default.
        #
        # It respects the server's configured timezone from +config/application.rb+.
        #
        def set_timezone(&action)
          timezone = if timezone_change_needed?
            resolved_timezone || Time.zone.name
          else
            session[:solidus_timezone]
          end
          session[:solidus_timezone] = timezone
          Time.use_zone(timezone, &action)
        end

        # Checks if we need to change the timezone or not.
        def timezone_change_needed?
          params[:solidus_timezone].present? || session[:solidus_timezone].blank?
        end

        # Returns the first valid timezone from the priority chain, or nil.
        #
        # The priority order is:
        #
        #  * the passed parameter: +params[:solidus_timezone]+
        #  * the user's timezone preference
        #
        def resolved_timezone
          candidates = [params[:solidus_timezone], timezone_from_user].compact
          candidates.detect { |tz| ActiveSupport::TimeZone[tz].present? }
        end

        # Try to get the timezone from user settings.
        def timezone_from_user
          spree_current_user.try(:timezone).presence
        end
      end
    end
  end
end
