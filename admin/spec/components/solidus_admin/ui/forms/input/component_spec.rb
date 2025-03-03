# frozen_string_literal: true

require "spec_helper"

RSpec.describe SolidusAdmin::UI::Forms::Input::Component, type: :component do
  it "renders the overview preview" do
    render_preview(:overview)
    render_preview(:input_playground)
    render_preview(:select_playground)
    render_preview(:textarea_playground)
  end

  it "only accepts certain 'type' attributes for the input" do
    expect {
      render_inline(described_class.new(type: :button))
    }.to raise_error(ArgumentError, /unsupported type attribute: button/)
  end

  describe "with `tag: input`" do
    it "renders a text input" do
      render_inline(described_class.new(type: :text, name: "name", value: "value"))

      expect(page).to have_css("input[type='text'][name='name'][value='value']")
    end

    it "renders a password input" do
      render_inline(described_class.new(type: :password, name: "name", value: "value"))

      expect(page).to have_css("input[type='password'][name='name'][value='value']")
    end

    it "renders a number input" do
      render_inline(described_class.new(type: :number, name: "name", value: "value"))

      expect(page).to have_css("input[type='number'][name='name'][value='value']")
    end

    it "renders a date input" do
      render_inline(described_class.new(type: :date, name: "name", value: "2020-01-01"))

      expect(page).to have_css("input[type='date'][name='name'][value='2020-01-01']")
    end
  end

  describe "with `tag: :textarea`" do
    let(:element) { page.find("textarea") }

    context "with value passed" do
      let(:component) { described_class.new(tag: :textarea, name: "name", value: "Text inside a textarea") }

      it "renders textarea with value" do
        render_inline(component)

        aggregate_failures do
          expect(element).to have_content("Text inside a textarea")
          expect(element.value).to eq("Text inside a textarea")
        end
      end
    end

    context "without value passed" do
      let(:component) { described_class.new(tag: :textarea, name: "name") }

      it "renders textarea" do
        render_inline(component)

        aggregate_failures do
          expect(element.text).to be_blank
          expect(element.value).to be_blank
        end
      end
    end
  end
end
