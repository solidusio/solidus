# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Spree::Role, type: :model do
  describe '.non_base_roles' do
    subject do
      Spree::Role.non_base_roles
    end

    context 'when there is a custom role' do
      let(:role) { create(:role, name: 'custom role') }
      let(:admin_role) { create(:admin_role) }
      let(:default_role) { create(:role, name: 'default') }

      it { is_expected.to include(role) }
      it { is_expected.not_to include(admin_role, default_role) }
    end

    context 'when there is no custom roles' do
      it { is_expected.to be_empty }
    end
  end
end
