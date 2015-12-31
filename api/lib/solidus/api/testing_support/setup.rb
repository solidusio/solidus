module Spree
  module Api
    module TestingSupport
      module Setup
        def sign_in_as_admin!
          let!(:current_api_user) do
            stub_model(Solidus::LegacyUser, spree_roles: [Solidus::Role.new(name: 'admin')])
          end
        end
      end
    end
  end
end
