module Solidus
  module TestingSupport
    module Flash
      def assert_flash_success(flash)
        flash = convert_flash(flash)

        within("[class='flash success']") do
          expect(page).to have_content(flash)
        end
      end

      def assert_successful_update_message(resource)
        flash = Solidus.t(:successfully_updated, resource: Solidus.t(resource))
        assert_flash_success(flash)
      end

      private

      def convert_flash(flash)
        if flash.is_a?(Symbol)
          flash = Solidus.t(flash)
        end
        flash
      end
    end
  end
end
