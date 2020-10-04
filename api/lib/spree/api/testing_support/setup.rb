# frozen_string_literal: true

module Spree
  module Api
    module TestingSupport
      module Setup
        def sign_in_as_admin!
          let!(:current_api_user) do
            stub_model(Spree::LegacyUser, spree_roles: [Spree::Role.find_or_initialize_by(name: 'admin')])
          end
        end
      end
    end
  end
end
