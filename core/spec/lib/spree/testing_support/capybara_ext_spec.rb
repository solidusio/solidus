# frozen_string_literal: true

require "rails_helper"
require "selenium-webdriver"
require "spree/testing_support/capybara_ext"

RSpec.describe Spree::TestingSupport::CapybaraExt do
  subject(:page_object) do
    Class.new do
      include Spree::TestingSupport::CapybaraExt

      attr_reader :page

      def initialize(element:, page:)
        @element = element
        @page = page
      end

      def find(*) = @element
    end.new(element: element, page: page)
  end

  let(:element) { instance_double(Capybara::Node::Element, native: :native_element) }
  let(:page) { instance_double(Capybara::Session, execute_script: nil) }

  describe "#click_icon" do
    it "clicks the icon it finds" do
      allow(element).to receive(:click)

      page_object.click_icon(:edit)

      expect(element).to have_received(:click)
    end

    context "when a floating element intercepts the click" do
      before do
        allow(element).to receive(:click)
          .and_raise(Selenium::WebDriver::Error::ElementClickInterceptedError)
      end

      it "scrolls the element into view and clicks it via JavaScript" do
        page_object.click_icon(:edit)

        expect(page).to have_received(:execute_script)
          .with('arguments[0].scrollIntoView({block: "center"});', :native_element).ordered
        expect(page).to have_received(:execute_script)
          .with("arguments[0].click();", :native_element).ordered
      end
    end

    context "when finding the icon is itself intercepted" do
      subject(:page_object) do
        Class.new do
          include Spree::TestingSupport::CapybaraExt

          attr_reader :page

          def initialize(page:)
            @page = page
          end

          def find(*)
            raise Selenium::WebDriver::Error::ElementClickInterceptedError
          end
        end.new(page: page)
      end

      # The fallback needs an element to scroll to, so a failure to find one has to
      # surface as itself rather than as a NoMethodError on nil.
      it "lets the error through instead of retrying without an element" do
        expect { page_object.click_icon(:edit) }
          .to raise_error(Selenium::WebDriver::Error::ElementClickInterceptedError)
      end
    end
  end
end
