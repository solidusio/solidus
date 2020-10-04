# frozen_string_literal: true

module Spree
  module TestingSupport
    module Flash
      def assert_flash_success(flash)
        flash = convert_flash(flash)

        within("[class='flash success']") do
          expect(page).to have_content(flash)
        end
      end

      def assert_successful_update_message(resource)
        flash = I18n.t('spree.successfully_updated', resource: I18n.t(resource, scope: 'spree'))
        assert_flash_success(flash)
      end

      private

      def convert_flash(flash)
        if flash.is_a?(Symbol)
          flash = I18n.t(flash, scope: 'spree')
        end
        flash
      end
    end
  end
end
