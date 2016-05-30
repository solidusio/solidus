module Capybara
  module Selectors
    module TagSelector
      def select2_tag(value, options = {})
        if options[:from]
          find(:fillable_field, options[:from]).set(value)
        else
          find('input.select2-input').set(value)
        end

        find('.select2-drop li', text: value).click
      end
    end
  end

  module Select2
    def select2_4(values, options = {})
      raise "Must pass a hash containing 'from' or 'xpath' or 'css'" unless options.is_a?(Hash) && [:from, :xpath, :css].any? { |k| options.key? k }

      if options.key? :xpath
        select2_container = find(:xpath, options[:xpath])
      elsif options.key? :css
        select2_container = find(:css, options[:css])
      else
        select2_container = find_label_by_text(options[:from]).find(:xpath, '..').find(".select2-container")
      end

      # Open select2 field
      if select2_container.has_selector?(".select2-selection")
        # select2 version 4.0
        select2_container.find(".select2-selection").click
      elsif select2_container.has_selector?(".select2-choice")
        select2_container.find(".select2-choice").click
      else
        select2_container.find(".select2-choices").click
      end

      if options.key? :search
        find(:xpath, "//body").find(".select2-search input.select2-search__field").set(values)
        page.execute_script(%|$("input.select2-search__field:visible").keyup();|)
        drop_container = ".select2-results"
      elsif find(:xpath, "//body").has_selector?(".select2-dropdown")
        # select2 version 4.0
        drop_container = ".select2-dropdown"
      else
        drop_container = ".select2-drop"
      end

      [values].flatten.each do |value|
        if find(:xpath, "//body").has_selector?("#{drop_container} li.select2-results__option")
          # select2 version 4.0
          find(:xpath, "//body").find("#{drop_container} li.select2-results__option", text: /#{Regexp.escape(value)}/i, match: :prefer_exact).click

        else
          find(:xpath, "//body").find("#{drop_container} li.select2-result-selectable", text: value).click
        end
      end
    end
  end
end

RSpec.configure do |config|
  config.include Capybara::Select2
  config.include Capybara::Selectors::TagSelector
end
