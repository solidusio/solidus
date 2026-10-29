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

      def panel(title:)
        find("section", text: title).find(:xpath, "..")
      end

      # Select options from a "solidus-select" field
      #
      # @param value [String, Array<String>] which option(s) to select
      # @param from [String] label of the select box
      def solidus_select(value, from:)
        controls = solidus_select_controls(from)

        # Initiate option loading.
        controls[:control].click

        # Wait until options have finished loaded. This accounts for select
        # instances that load data from a remote data source URL on click. We
        # want the exact text to contain at least one character, as options
        # will at first load with "" as text values, causing timing-related
        # test failures.
        controls[:dropdown].first(".option", exact_text: /.+/)

        Array.wrap(value).each do |val|
          option = controls[:dropdown].first(".option", exact_text: val)

          if option
            option.click
          else
            controls[:input].fill_in(with: val).send_keys(:return)
          end

          # Reload the select controls in case they have been replaced by
          # new DOM elements. This can happen, for example, when a select
          # element is hooked up to Turbo controller JavaScript function.
          controls = solidus_select_controls(from)
          expect(controls[:control]).to have_text(val)
        end
      end

      def solidus_unselect(value, from:)
        input = find_field(from, visible: :all)
        Array.wrap(value).each do |val|
          item = input.sibling("div", text: val)
          item.find("a").click
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

      def accept_turbo_confirm(title)
        yield
        dialog = find("dialog", text: title)
        within(dialog) { find_button(id: "confirm-accept").click }
      end

      def switch(locator, on: true)
        checkbox = find(:label, text: locator).find(:checkbox)
        on ? checkbox.check : checkbox.uncheck
      end

      def dialog(parent: "body", **options)
        within(parent) do
          find("dialog", visible: :all, **options)
        end
      end

      def turbo_frame_modal
        dialog(parent: find("turbo-frame", visible: :all))
      end

      private

      def solidus_select_controls(from)
        input = find_field(from, visible: :all)
        control = input.ancestor(".control")
        dropdown = control.sibling(".dropdown", visible: :all)

        {input:, control:, dropdown:}
      end
    end
  end
end
