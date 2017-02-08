module Spree
  module Admin
    class LocalesController < Spree::Admin::BaseController
      def show
      end

      def update
        params.each do |name, value|
          next unless SolidusI18n::Config.has_preference? name
          SolidusI18n::Config[name] = value.map(&:to_sym)
        end
        redirect_to admin_locale_path
      end
    end
  end
end
