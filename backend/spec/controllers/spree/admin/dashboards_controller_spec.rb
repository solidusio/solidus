# frozen_string_literal: true

require 'spec_helper'

describe Spree::Admin::DashboardsController, type: :controller do
    it 'displays a warning' do
      expect(Spree.deprecator).to receive(:deprecate)
    end
end
