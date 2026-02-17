# frozen_string_literal: true

module Spree
  module TestingSupport
    module CapybaraExt
      def click_icon(type)
        el = find(".fa-#{type}", visible: :all)
        el.click
      rescue Selenium::WebDriver::Error::ElementClickInterceptedError
        # When a floating element (eg. tooltips/overlays) intercepts the click,
        # scroll the target into view and dispatch a click via JS to keep tests stable.
        page.execute_script('arguments[0].scrollIntoView({block: "center"});', el.native)
        page.execute_script('arguments[0].click();', el.native)
      end

      def eventually_fill_in(field, options = {})
        expect(page).to have_css('#' + field)
        fill_in field, options
      end

      def fill_in_with_force(locator, with:)
        if Capybara.current_driver == Capybara.javascript_driver
          field_id = find_field(locator)[:id]
          page.execute_script <<-JS
            var field = document.getElementById('#{field_id}');
            field.value = '#{with}';

            var event = new Event('change', { bubbles: true });
            field.dispatchEvent(event);
          JS
        else
          fill_in locator, with:
        end
      end

      def within_row(num, &block)
        within("table.index tbody tr:nth-of-type(#{num})", &block)
      end

      def column_text(num)
        find("td:nth-of-type(#{num})").text
      end

      def select2_search(value, options)
        options = {
          search: value, # by default search for the value
          select: true
        }.merge(options)
        label = find_label_by_text(options[:from])
        within label.first(:xpath, ".//..") do
          options[:from] = "##{find('.select2-container')['id']}"
        end
        select2_search_without_selection(options[:search], from: options[:from])
        select_select2_result(value) if options[:select]
      end

      def select2_search_without_selection(value, options)
        find("#{options[:from]}:not(.select2-container-disabled):not(.select2-offscreen)").click

        within_entire_page do
          find("input.select2-input.select2-focused").set(value)
        end
      end

      def targetted_select2_search(value, options)
        select2_search_without_selection(value, from: options[:from])
        select_select2_result(value)
      end

      # Executes the given block within the context of the entire capybara
      # document. Can be used to 'escape' from within the context of another within
      # block.
      def within_entire_page(&block)
        within(:xpath, '//body', &block)
      end

      def select2(value, options)
        label = find_label_by_text(options[:from])

        within label.first(:xpath, ".//..") do
          options[:from] = "##{find('.select2-container')['id']}"
        end
        targetted_select2(value, options)
      end

      def select2_no_label(value, options = {})
        raise "Must pass a hash containing 'from'" if !options.is_a?(Hash) || !options.key?(:from)

        placeholder = options[:from]

        click_link placeholder

        select_select2_result(value)
      end

      def targetted_select2(value, options)
        # find select2 element and click it
        find(options[:from]).find('a').click
        select_select2_result(value)
      end

      def select_select2_result(value)
        # results are in a div appended to the end of the document
        within_entire_page do
          expect(page).to have_selector('.select2-result-label', visible: true)
          find("div.select2-result-label", text: /#{Regexp.escape(value)}/i, match: :prefer_exact).click
          expect(page).not_to have_selector('.select2-result-label')
        end
      end

      def find_label_by_text(text)
        # This used to find the label by it's text using an xpath query, so we use
        # a case insensitive search to avoid breakage with existing usage.
        # We need to select labels which are not .select2-offscreen, as select2
        # makes a duplicate label with the same text, and we want to be sure to
        # find the original.
        find('label:not(.select2-offscreen)', text: /#{Regexp.escape(text)}/i, match: :one)
      end

      def dialog(parent: 'body', **options)
        within(parent) do
          find('dialog', visible: :all, **options)
        end
      end

      def turbo_frame_modal
        dialog(parent: find('turbo-frame', visible: :all))
      end
    end
  end
end

RSpec::Matchers.define :have_meta do |name, expected|
  match do |_actual|
    has_css?("meta[name='#{name}'][content='#{expected}']", visible: false)
  end

  failure_message do
    actual = first("meta[name='#{name}']")
    if actual
      "expected that meta #{name} would have content='#{expected}' but was '#{actual[:content]}'"
    else
      "expected that meta #{name} would exist with content='#{expected}'"
    end
  end
end

RSpec.configure do |c|
  c.include Spree::TestingSupport::CapybaraExt
end

# A workaround for https://github.com/rspec/rspec-rails/issues/1897
Capybara.server = :puma, { Silent: true }
