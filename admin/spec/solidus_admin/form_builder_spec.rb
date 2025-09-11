# frozen_string_literal: true

require "spec_helper"

RSpec.describe SolidusAdmin::FormBuilder do
  let(:object) { Spree::Product.new }
  let(:builder) do
    described_class.new(:product, object, ActionView::Base.empty, {html: {id: "_form"}})
  end

  describe "#text_field" do
    it "renders a text input" do
      result = builder.text_field(:name)
      expect(result).to include("<input")
    end
  end

  describe "#text_area" do
    it "renders a text area" do
      expect(builder.text_area(:description)).to include("<textarea")
    end
  end

  describe "#select" do
    it "renders a select box" do
      expect(builder.select(:condition, [])).to include("<select")
    end
  end

  describe "#checkbox" do
    it "renders a checkbox" do
      result = builder.checkbox(:promotionable, checked: false)
      expect(result).to include("<input")
      expect(result).to include("type=\"checkbox\"")
      expect(result).not_to include("checked=\"checked\"")
    end

    context "when :checked is not passed" do
      it "renders with correct checked value" do
        builder.object.promotionable = false
        expect(builder.checkbox(:promotionable)).not_to include("checked=\"checked\"")

        builder.object.promotionable = true
        expect(builder.checkbox(:promotionable)).to include("checked=\"checked\"")
      end
    end

    context "with custom label" do
      it "renders with custom label" do
        expect(builder.checkbox(:promotionable, label: "Promo-able")).to include("Promo-able")
      end
    end

    context "with hint" do
      it "renders with hint" do
        expect(builder.checkbox(:promotionable, hint: "Helpful info")).to include("Helpful info")
      end
    end
  end

  describe "#checkbox_row" do
    it "renders checkboxes" do
      result = builder.checkbox_row(
        :taxon_ids,
        options: [{id: 1, label: "One"}, {id: 2, label: "Two"}],
        row_title: "Taxons"
      )
      expect(result).to include("<input").twice
      expect(result).to include("type=\"checkbox\"").twice
      expect(result).to include("One")
      expect(result).to include("Two")
      expect(result).to include("Taxons")
    end
  end

  describe "#input" do
    it "renders an input of given type" do
      object.name = "Product"
      result = builder.input(:name, type: :text)
      expect(result).to match(%r{<input.+type="text"})
      expect(result).to include("value=\"Product\"")
      expect(result).to include("name=\"product[name]\"")
    end

    context "with value passed" do
      it "renders with correct value" do
        expect(builder.input(:name, value: "Cap")).to include("value=\"Cap\"")
      end
    end
  end

  describe "#hidden_field" do
    it "renders a hidden input" do
      result = builder.hidden_field(:tax_category_id)
      expect(result).to match(%r{<input.+type="hidden"})
    end
  end

  describe "#switch_field" do
    it "renders a switch field" do
      object.promotionable = false
      object.errors.add(:promotionable, :invalid, message: "cannot be on")
      result = builder.switch_field(:promotionable, label: "Promotionable")
      expect(result).to include("Promotionable")
      expect(result).to include("<input")
      expect(result).to include("type=\"checkbox\"")
      expect(result).not_to include("checked=\"checked\"")
      expect(result).to include("cannot be on")
    end

    context "with default label" do
      it "renders label with default name for field" do
        result = builder.switch_field(:promotionable)
        expect(result).to include("Promotable")
      end
    end
  end

  describe "#submit" do
    it "renders submit button" do
      result = builder.submit
      expect(result).to include("<button")
      expect(result).to include("type=\"submit\"")
      expect(result).to include("form=\"_form\"")
    end

    context "when custom text passed" do
      it "renders custom text" do
        expect(builder.submit(text: "Submit")).to include("Submit")
      end
    end
  end
end
