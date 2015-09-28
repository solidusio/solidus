require 'spec_helper'

module Spree
  describe LegacyUser, :type => :model do
    let(:user) { LegacyUser.new }

    it "can generate an API key" do
      expect(user).to receive(:save!)
      expect { user.generate_spree_api_key! }.to change(user, :spree_api_key).to be_present
    end

    it "can generate an API key without persisting" do
      expect(user).not_to receive(:save!)
      expect { user.generate_spree_api_key }.to change(user, :spree_api_key).to be_present
    end

    it "can clear an API key" do
      user.spree_api_key = 'abc123'
      expect(user).to receive(:save!)
      expect { user.clear_spree_api_key! }.to change(user, :spree_api_key).to be_blank
    end

    it "can clear an api key without persisting" do
      user.spree_api_key = 'abc123'
      expect(user).not_to receive(:save!)
      expect { user.clear_spree_api_key }.to change(user, :spree_api_key).to be_blank
    end

    context "admin role auto-api-key grant" do # so the admin user can do admin api actions
      let(:user) { create(:user) }
      before { expect(user.spree_roles).to be_blank }
      subject { user.spree_roles << role }

      context "admin role" do
        let(:role) { create(:role, name: "admin") }

        context "the user has no api key" do
          before { user.clear_spree_api_key! }
          it { expect { subject }.to change { user.reload.spree_api_key }.from(nil) }
        end

        context "the user already has an api key" do
          before { user.generate_spree_api_key! }
          it { expect { subject }.not_to change { user.reload.spree_api_key } }
        end
      end

      context "non-admin role" do
        let(:role) { create(:role, name: "foo") }
        before { user.clear_spree_api_key! }
        it { expect { subject }.not_to change { user.reload.spree_api_key } }
      end
    end
  end
end
