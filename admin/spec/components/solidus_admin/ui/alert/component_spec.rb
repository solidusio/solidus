# frozen_string_literal: true

require "spec_helper"

RSpec.describe SolidusAdmin::UI::Alert::Component, type: :component do
  it "renders the overview preview" do
    render_preview(:overview)
  end

  describe "defaults" do
    let(:component) { described_class.new(title:, description:, scheme:) }
    let(:title) { "Title" }
    let(:description) { "Description" }
    let(:scheme) { :success }

    context "when title is not present" do
      let(:title) { nil }

      shared_examples_for "with default title" do |scheme, expected_title|
        let(:scheme) { scheme }

        it "renders default title for scheme #{scheme}" do
          render_inline(component)
          expect(page).to have_content(expected_title)
        end
      end

      it_behaves_like "with default title", :success, "Success"
      it_behaves_like "with default title", :warning, "Warning"
      it_behaves_like "with default title", :danger, "Caution"
      it_behaves_like "with default title", :info, "Info"
    end
  end
end
