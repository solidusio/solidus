# frozen_string_literal: true

require 'rails_helper'
require 'spree/core/controller_helpers/current_host'

RSpec.describe Spree::Core::ControllerHelpers::CurrentHost do
  it 'is deprecated' do
    expect(Spree::Deprecation).to receive(:warn).with(/'#{described_class.name}' is deprecated/)

    Class.new(ApplicationController).include(described_class)
  end

  it 'includes ActiveStorage::SetCurrent module' do
    Spree::Deprecation.silence do
      mod = Class.new(ApplicationController).include(described_class)

      expect(mod.ancestors).to include(ActiveStorage::SetCurrent)
    end
  end
end
