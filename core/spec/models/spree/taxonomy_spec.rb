# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Spree::Taxonomy, type: :model do
  context "#destroy" do
    subject(:association_options) do
      described_class.reflect_on_association(:root).options
    end

    it "should destroy all associated taxons" do
      expect(association_options[:dependent]).to eq :destroy
    end
  end
end
