require 'spec_helper'

module Solidus
  describe LegacyUser, :type => :model do
    let(:user) { LegacyUser.new }

    it "can generate an API key" do
      expect(user).to receive(:save!)
      expect { user.generate_solidus_api_key! }.to change(user, :solidus_api_key).to be_present
    end

    it "can generate an API key without persisting" do
      expect(user).not_to receive(:save!)
      expect { user.generate_solidus_api_key }.to change(user, :solidus_api_key).to be_present
    end

    it "can clear an API key" do
      user.solidus_api_key = 'abc123'
      expect(user).to receive(:save!)
      expect { user.clear_solidus_api_key! }.to change(user, :solidus_api_key).to be_blank
    end

    it "can clear an api key without persisting" do
      user.solidus_api_key = 'abc123'
      expect(user).not_to receive(:save!)
      expect { user.clear_solidus_api_key }.to change(user, :solidus_api_key).to be_blank
    end

    context "auto-api-key grant" do
      context "after role user create" do
        let(:user) { create(:user) }
        before { expect(user.solidus_roles).to be_blank }
        subject { user.solidus_roles << role }

        context "roles_for_auto_api_key default" do
          let(:role) { create(:role, name: "admin") }

          context "the user has no api key" do
            before { user.clear_solidus_api_key! }
            it { expect { subject }.to change { user.reload.solidus_api_key }.from(nil) }
          end

          context "the user already has an api key" do
            before { user.generate_solidus_api_key! }
            it { expect { subject }.not_to change { user.reload.solidus_api_key } }
          end
        end

        context "roles_for_auto_api_key is defined" do
          let (:role) { create(:role, name: 'hobbit') }
          let(:undesired_role) { create(:role, name: "foo") }

          before {
            user.clear_solidus_api_key!
            Solidus::Config.roles_for_auto_api_key = ['hobbit']
          }

          it { expect { subject }.to change { user.reload.solidus_api_key }.from(nil) }
          it { expect { user.solidus_roles << undesired_role }.not_to change { user.reload.solidus_api_key } }
        end

        context "for all roles" do
          let (:role) { create(:role, name: 'hobbit') }
          let (:other_role) { create(:role, name: 'wizard') }
          let (:other_user) { create(:user) }

          before {
            user.clear_solidus_api_key!
            other_user.clear_solidus_api_key!
            Solidus::Config.generate_api_key_for_all_roles = true
          }

          it { expect { subject }.to change { user.reload.solidus_api_key }.from(nil) }
          it { expect { other_user.solidus_roles << other_role }.to change { other_user.reload.solidus_api_key }.from(nil) }
        end
      end

      context "after user create" do
        let(:user) { LegacyUser.new }

        context "generate_api_key_for_all_roles" do
          it "does not grant api key default" do
            expect(user.solidus_api_key).to eq(nil)

            user.save!
            expect(user.solidus_api_key).to eq(nil)
          end

          it "grants an api key on create when set to true" do
            Solidus::Config.generate_api_key_for_all_roles = true

            expect(user.solidus_api_key).to eq(nil)

            user.save!
            expect(user.solidus_api_key).not_to eq(nil)
          end
        end
      end
    end
  end
end
