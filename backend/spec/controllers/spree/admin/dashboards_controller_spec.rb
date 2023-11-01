require 'spec_helper'

describe Spree::Admin::DashboardsController, type: :controller do
    it 'emits a warning' do
      expect(Spree.deprecator).to receive(:warn)
    end
end
