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
  end
end
