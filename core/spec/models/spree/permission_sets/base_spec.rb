# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Spree::PermissionSets::Base do
  let(:ability) { Spree::Ability.new nil }
  subject { described_class.new(ability).activate! }

  describe "activate!" do
    it "raises a not implemented error" do
      expect{ subject }.to raise_error(NotImplementedError)
    end
  end
end
