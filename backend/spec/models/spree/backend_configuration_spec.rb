require 'spec_helper'

describe Spree::BackendConfiguration, type: :model do
  let(:prefs) { Spree::Backend::Config }

  describe '#use_turbolinks' do
    specify { expect(prefs).to respond_to(:use_turbolinks) }
  end
end
