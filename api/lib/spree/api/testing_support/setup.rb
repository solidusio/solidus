module Spree
  module Api
    module TestingSupport
      module Setup
        def sign_in_as_admin!
          let!(:current_api_user) do
            create(:admin_user)
          end
        end
      end
    end
  end
end
