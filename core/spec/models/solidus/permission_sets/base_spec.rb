# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Solidus::PermissionSets::Base do
  let(:ability) { Solidus::Ability.new nil }
  subject { described_class.new(ability).activate! }

  describe "activate!" do
    it "raises a not implemented error" do
      expect{ subject }.to raise_error(NotImplementedError)
    end
  end
end
