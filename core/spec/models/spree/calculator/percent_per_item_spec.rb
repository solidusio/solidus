require 'spec_helper'

module Spree
  class Calculator
    describe PercentPerItem, type: :model do
      describe ".description" do
        subject { described_class.description }
        it { is_expected.to eq("Percent Per Item") }
      end
    end
  end
end
