# frozen_string_literal: true

require "spec_helper"

RSpec.describe SolidusAdmin::UI::Forms::Select::Component, type: :component do
  describe "#call" do
    before do
      country = create :country
      create :state, country:, state_code: "AL"
      create :state, country:, state_code: "AK"
      create :state, country:, state_code: "AZ"
    end

    it "renders the overview preview" do
      render_preview(:overview)
    end

    it "renders the playground preview" do
      render_preview(:playground)
    end
  end

  describe "#attributes" do
    subject { component.attributes(request_context:) }

    let(:component) {
      described_class.new(label: "label", name: "given-name", choices: [], src:)
    }

    context "when the component is not given a remote data source URL" do
      let(:request_context) { double }
      let(:src) { nil }

      it "returns the initialized attributes", :aggregate_failures do
        expect(subject.keys).to contain_exactly :class,
          :id,
          :is,
          :name,
          :"data-error-message"

        expect(subject).to include(name: "given-name")
      end

      it "does not include a 'data-src' attribute" do
        expect(subject[:"data-src"]).to be_nil
      end
    end

    context "when the component is given an absolute remote data source URL" do
      let(:request_context) { double }
      let(:src) { "https://example.com/rabbit-species" }

      it "returns the initialized attributes", :aggregate_failures do
        expect(subject.keys).to contain_exactly :class,
          :id,
          :is,
          :name,
          :"data-error-message",
          :"data-src"

        expect(subject).to include(name: "given-name")
      end

      it "includes the 'data-src' attribute as given" do
        expect(subject[:"data-src"]).to eq "https://example.com/rabbit-species"
      end
    end

    context "when the component is given a relative remote data source URL" do
      let(:src) { "/admin/rabbit-species" }

      context "and the request context indicates a host using a non-standard port" do
        let(:request_context) {
          ActionDispatch::Request.new(
            Rack::MockRequest.env_for("http://localhost:1234/admin/products/123")
          )
        }

        it "returns the initialized attributes", :aggregate_failures do
          expect(subject.keys).to contain_exactly :class,
            :id,
            :is,
            :name,
            :"data-error-message",
            :"data-src"

          expect(subject).to include(name: "given-name")
        end

        it "includes the 'data-src' attribute as given" do
          expect(subject[:"data-src"])
            .to eq "http://localhost:1234/admin/rabbit-species"
        end
      end

      context "and the request context indicates a host using a standard port" do
        let(:request_context) {
          ActionDispatch::Request.new(
            Rack::MockRequest.env_for("https://example.com/admin/products/123")
          )
        }

        it "returns the initialized attributes", :aggregate_failures do
          expect(subject.keys).to contain_exactly :class,
            :id,
            :is,
            :name,
            :"data-error-message",
            :"data-src"

          expect(subject).to include(name: "given-name")
        end

        it "includes the 'data-src' attribute as given" do
          expect(subject[:"data-src"])
            .to eq "https://example.com/admin/rabbit-species"
        end
      end
    end
  end
end
