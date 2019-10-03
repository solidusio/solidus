# frozen_string_literal: true

module Solidus
  module Api
    module TestingSupport
      module Setup
        def sign_in_as_admin!
          let!(:current_api_user) do
            stub_model(Solidus::LegacyUser, spree_roles: [Solidus::Role.find_or_initialize_by(name: 'admin')])
          end
        end
      end
    end
  end
end
