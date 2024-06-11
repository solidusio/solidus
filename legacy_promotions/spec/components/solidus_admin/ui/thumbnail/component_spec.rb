# frozen_string_literal: true

require "rails_helper"

RSpec.describe SolidusAdmin::UI::Thumbnail::Component, type: :component do
  describe ".for" do
    let(:promotion_action) { Spree::PromotionAction.new }

    subject { render_inline described_class.for(promotion_action) }

    it "displays a megaphone" do
      subject
      expect(page).to have_xpath("//use[contains(@*, '#ri-megaphone')]")
    end
  end
end
