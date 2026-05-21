# frozen_string_literal: true

require 'solidus_starter_frontend_spec_helper'

RSpec.describe 'User update', type: :request do
  context 'CSRF protection' do
    %i[exception reset_session null_session].each do |strategy|
      # Completely clean the configuration of forgery protection for the
      # controller and reset it after the expectations. However, besides `:with`,
      # the options given to `protect_from_forgery` are processed on the fly.
      # I.e., there's no way to retain them. The initial setup corresponds to the
      # dummy application, which uses the default Rails skeleton in that regard.
      # So, if at some point Rails changed the given options, we should update it
      # here.
      around do |example|
        controller = UsersController
        old_allow_forgery_protection_value = controller.allow_forgery_protection
        old_forgery_protection_strategy = controller.forgery_protection_strategy
        controller.skip_forgery_protection
        controller.allow_forgery_protection = true
        controller.protect_from_forgery with: strategy

        example.run

        controller.allow_forgery_protection = old_allow_forgery_protection_value
        controller.forgery_protection_strategy = old_forgery_protection_strategy
      end

      it "is not possible to take account over with the #{strategy} forgery protection strategy" do
        user = create(:user, email: 'legit@mail.com', password: 'password')

        post '/login', params: "spree_user[email]=legit@mail.com&spree_user[password]=password"
        begin
          put '/users/123456', params: 'user[email]=hacked@example.com'
        rescue
          # testing that the account is not compromised regardless of any raised
          # exception
        end

        expect(user.reload.email).to eq('legit@mail.com')
      end
    end
  end
end
