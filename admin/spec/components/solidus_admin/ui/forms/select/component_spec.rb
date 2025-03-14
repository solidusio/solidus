# frozen_string_literal: true

require "spec_helper"

RSpec.describe SolidusAdmin::UI::Forms::Select::Component, type: :component do
  it "renders the overview preview" do
    render_preview(:overview)
  end

  it "renders the playground preview" do
    render_preview(:playground)
  end

  describe "passing additional stimulus data attributes" do
    let(:component) { described_class.new(label: "Select", name: "name", choices: [], **data_attributes) }
    let(:element) { page.find("select") }

    shared_examples_for "renders correct data attributes" do
      it "renders correct data attributes" do
        render_inline(component)

        aggregate_failures do
          expect(element["data-controller"]).to eq "custom-validity controller"
          expect(element["data-action"]).to eq "custom-validity#clearCustomValidity controller#action"
        end
      end
    end

    context "inline" do
      let(:data_attributes) { { "data-controller": "controller", "data-action" => "controller#action" } }

      include_examples "renders correct data attributes"
    end

    context "as a hash" do
      let(:data_attributes) do
        {
          data: {
            "controller" => "controller",
            action: "controller#action"
          }
        }
      end

      include_examples "renders correct data attributes"
    end
  end
end
