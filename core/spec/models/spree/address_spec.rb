require 'spec_helper'

describe Spree::Address, :type => :model do

  subject { Spree::Address }

  context "aliased attributes" do
    let(:address) { Spree::Address.new firstname: 'Ryan', lastname: 'Bigg'}

    it " first_name" do
      expect(address.first_name).to eq("Ryan")
    end

    it "last_name" do
      expect(address.last_name).to eq("Bigg")
    end
  end

  context "validation" do

    let(:country) { mock_model(Spree::Country, :states => [state], :states_required => true) }
    let(:state) { stub_model(Spree::State, :name => 'maryland', :abbr => 'md') }
    let(:address) { build(:address, :country => country) }

    before do
      allow(country.states).to receive_messages :find_all_by_name_or_abbr => [state]
    end

    context 'address does not require state' do
      before do
        Spree::Config.address_requires_state = false
      end
      it "address_requires_state preference is false" do
        address.state = nil
        address.state_name = nil
        expect(address).to be_valid
      end
    end

    context 'address requires state' do
      before do
        Spree::Config.address_requires_state = true
      end

      it "state_name is not nil and country does not have any states" do
        address.state = nil
        address.state_name = 'alabama'
        expect(address).to be_valid
      end

      it "errors when state_name is nil" do
        address.state_name = nil
        address.state = nil
        expect(address).not_to be_valid
      end

      it "full state name is in state_name and country does contain that state" do
        address.state_name = 'alabama'
        # called by state_validate to set up state_id.
        # Perhaps this should be a before_validation instead?
        expect(address).to be_valid
        expect(address.state).not_to be_nil
        expect(address.state_name).to be_nil
      end

      it "state abbr is in state_name and country does contain that state" do
        address.state_name = state.abbr
        expect(address).to be_valid
        expect(address.state_id).not_to be_nil
        expect(address.state_name).to be_nil
      end

      it "state is entered but country does not contain that state" do
        address.state = state
        address.country = stub_model(Spree::Country, :states_required => true)
        address.valid?
        expect(address.errors["state"]).to eq(['is invalid'])
      end

      it "both state and state_name are entered but country does not contain the state" do
        address.state = state
        address.state_name = 'maryland'
        address.country = stub_model(Spree::Country, :states_required => true)
        expect(address).to be_valid
        expect(address.state_id).to be_nil
      end

      it "both state and state_name are entered and country does contain the state" do
        address.state = state
        address.state_name = 'maryland'
        expect(address).to be_valid
        expect(address.state_name).to be_nil
      end
    end

    it "requires phone" do
      address.phone = ""
      address.valid?
      expect(address.errors["phone"]).to eq(["can't be blank"])
    end

    it "requires zipcode" do
      address.zipcode = ""
      address.valid?
      expect(address.errors['zipcode']).to include("can't be blank")
    end

    context "zipcode validation" do
      it "validates the zipcode" do
        allow(address.country).to receive(:iso).and_return('US')
        address.zipcode = 'abc'
        address.valid?
        expect(address.errors['zipcode']).to include('is invalid')
      end

      context 'does not validate' do
        it 'does not have a country' do
          address.country = nil
          address.valid?
          expect(address.errors['zipcode']).not_to include('is invalid')
        end

        it 'does not have an iso' do
          allow(address.country).to receive(:iso).and_return(nil)
          address.valid?
          expect(address.errors['zipcode']).not_to include('is invalid')
        end

        it 'does not have a zipcode' do
          address.zipcode = ""
          address.valid?
          expect(address.errors['zipcode']).not_to include('is invalid')
        end

        it 'does not have a supported country iso' do
          allow(address.country).to receive(:iso).and_return('BO')
          address.valid?
          expect(address.errors['zipcode']).not_to include('is invalid')
        end
      end
    end

    context "phone not required" do
      before { allow(address).to receive_messages require_phone?: false }

      it "shows no errors when phone is blank" do
        address.phone = ""
        address.valid?
        expect(address.errors[:phone].size).to eq 0
      end
    end

    context "zipcode not required" do
      before { allow(address).to receive_messages require_zipcode?: false }

      it "shows no errors when phone is blank" do
        address.zipcode = ""
        address.valid?
        expect(address.errors[:zipcode].size).to eq 0
      end
    end
  end

  context ".build_default" do
    context "no user given" do
      let!(:default_country) { create(:country) }

      context 'has a default country' do
        before do
          Spree::Config[:default_country_id] = default_country.id
        end

        it "sets up a new record with Spree::Config[:default_country_id]" do
          expect(Spree::Address.build_default.country).to eq default_country
        end
      end

      # Regression test for #1142
      it "uses the first available country if :default_country_id is set to an invalid value" do
        Spree::Config[:default_country_id] = "0"
        expect(Spree::Address.build_default.country).to eq default_country
      end
    end
  end

  context ".immutable_merge" do
    RSpec::Matchers.define :be_address_equivalent_attributes do |expected|
      fields_of_interest = [:firstname, :lastname, :company, :address1, :address2, :city, :zipcode, :phone, :alternative_phone]
      match do |actual|
        expected_attrs = expected.slice(*fields_of_interest)
        actual_attrs = actual.symbolize_keys.slice(*fields_of_interest)
        expected_attrs == actual_attrs
      end
    end

    let(:new_address_attributes) { attributes_for(:address) }
    subject { Spree::Address.immutable_merge(existing_address, new_address_attributes) }

    context "no existing address" do
      let(:existing_address) { nil }

      it "returns new Address matching attributes given" do
        expect(subject.attributes).to be_address_equivalent_attributes(new_address_attributes)
      end
    end

    context "with existing address" do
      let(:existing_address) { create(:address) }

      it "returns a new Address of merged data" do
        merged_attributes = subject.attributes.merge(new_address_attributes.symbolize_keys)
        expect(subject.attributes).to be_address_equivalent_attributes merged_attributes
        expect(subject.id).not_to eq existing_address.id
      end

      context "and no changes to attributes" do
        let(:new_address_attributes) { existing_address.attributes }

        it "returns existing address" do
          expect(subject).to eq existing_address
          expect(subject.id).to eq existing_address.id
        end
      end
    end
  end

  context '#full_name' do
    context 'both first and last names are present' do
      let(:address) { stub_model(Spree::Address, :firstname => 'Michael', :lastname => 'Jackson') }
      specify { expect(address.full_name).to eq('Michael Jackson') }
    end

    context 'first name is blank' do
      let(:address) { stub_model(Spree::Address, :firstname => nil, :lastname => 'Jackson') }
      specify { expect(address.full_name).to eq('Jackson') }
    end

    context 'last name is blank' do
      let(:address) { stub_model(Spree::Address, :firstname => 'Michael', :lastname => nil) }
      specify { expect(address.full_name).to eq('Michael') }
    end

    context 'both first and last names are blank' do
      let(:address) { stub_model(Spree::Address, :firstname => nil, :lastname => nil) }
      specify { expect(address.full_name).to eq('') }
    end

  end

  context '#state_text' do
    context 'state is blank' do
      let(:address) { stub_model(Spree::Address, :state => nil, :state_name => 'virginia') }
      specify { expect(address.state_text).to eq('virginia') }
    end

    context 'both name and abbr is present' do
      let(:state) { stub_model(Spree::State, :name => 'virginia', :abbr => 'va') }
      let(:address) { stub_model(Spree::Address, :state => state) }
      specify { expect(address.state_text).to eq('va') }
    end

    context 'only name is present' do
      let(:state) { stub_model(Spree::State, :name => 'virginia', :abbr => nil) }
      let(:address) { stub_model(Spree::Address, :state => state) }
      specify { expect(address.state_text).to eq('virginia') }
    end
  end

  context '#requires_phone' do
    subject { described_class.new }

    it { is_expected.to be_require_phone  }
  end
end
