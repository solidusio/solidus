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
        find("table tbody tr td", text:)
      end

      def find_row_checkbox(text)
        find("table tbody tr", text:).find('td:first-child input[type="checkbox"]')
      end

      def select_row(text)
        find_row_checkbox(text).tap do |checkbox|
          checkbox.check
          checkbox.synchronize { checkbox.checked? }
        end
      end

      # Select options from a "solidus-select" field
      #
      # @param value [String, Array<String>] which option(s) to select
      # @param from [String] label of the select box
      def solidus_select(value, from:)
        input = find_field(from, visible: :all)
        control = input.ancestor(".control")
        dropdown = control.sibling(".dropdown", visible: :all)

        # Make sure options are loaded
        control.click
        within(dropdown) { expect(first(".option", visible: :all)).to be }

        Array.wrap(value).each do |val|
          input.fill_in(with: val).send_keys(:return)
          expect(control).to have_text(val)
        end
      end

      def checkbox(locator)
        find(:checkbox, locator)
      end

      def clear_search
        within('div[role="search"]') do
          find('button[aria-label="Clear"]').click
        end
      end

      def solidus_select_control(field)
        find_field(field, visible: :all).ancestor(".control")
      end
    end
  end
end
