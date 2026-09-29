# frozen_string_literal: true

require "spec_helper"

RSpec.describe SolidusAdmin::UI::Forms::Field::Component, type: :component do
  before do
    create :product
    create_list :taxon, 3
  end

  it "renders the overview preview" do
    render_preview(:overview)
  end

  describe ".password_field" do
    subject { described_class.password_field form_double, :slug }

    let(:form_double) {
      double SolidusAdmin::FormBuilder,
        object: Spree::Product.new,
        object_name: "form_object_name"
    }

    it "renders a password input field", :aggregate_failures do
      expect(subject).to be_an_instance_of described_class

      input_attributes = subject.instance_variable_get(:@input_attributes)
      expect(input_attributes).to include(
        name: "form_object_name[slug]",
        type: :password,
        autocomplete: "off"
      )
    end
  end
end
