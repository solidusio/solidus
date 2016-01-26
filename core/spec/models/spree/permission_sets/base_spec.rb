require 'spec_helper'

describe Spree::PermissionSets::Base do
  let(:ability) { Spree::Ability.new nil }
  subject { described_class.new(ability).activate! }

  describe "activate!" do
    it "raises a not implemented error" do
      expect{ subject }.to raise_error(NotImplementedError)
    end
  end
end
