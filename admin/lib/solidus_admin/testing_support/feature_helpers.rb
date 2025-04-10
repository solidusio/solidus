# frozen_string_literal: true

module SolidusAdmin
  module TestingSupport
    module FeatureHelpers
      def sign_in(user)
        allow_any_instance_of(SolidusAdmin::BaseController).to receive(:spree_current_user).and_return(user)
      end

      def stub_authorization!(user)
        ability = Spree::Ability.new(user)
        if block_given?
          yield ability
        else
          ability.can :manage, :all
        end
        allow_any_instance_of(SolidusAdmin::BaseController).to receive(:current_ability).and_return(ability)
        allow_any_instance_of(Spree::Admin::BaseController).to receive(:current_ability).and_return(ability)
      end

      def find_row(text)
        find('table tbody tr', text:)
      end

      def find_row_checkbox(text)
        find_row(text).find('td:first-child input[type="checkbox"]')
      end

      def select_row(text)
        find_row_checkbox(text).tap do |checkbox|
          checkbox.check
          checkbox.synchronize { checkbox.checked? }
        end
      end

      # Select an option from a "solidus-select" field
      #
      # @param value [String] which option to select
      # @param from [String] label of the select box
      def solidus_select(value, from:)
        fill_in(from, with: value).send_keys(:return)
        expect(find_field(from).ancestor(".control")).to have_text(value)
      end
    end
  end
end
