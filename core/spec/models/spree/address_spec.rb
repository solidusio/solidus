# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Spree::Address, type: :model do
  context "aliased attributes" do
    before do
      allow(Spree::Deprecation).to receive(:warn).and_call_original
      allow(Spree::Deprecation).to receive(:warn).with(/firstname|lastname/, any_args)
    end

    let(:address) { Spree::Address.new firstname: 'Ryan', lastname: 'Bigg' }

    it " first_name" do
      expect(address.first_name).to eq("Ryan")
    end

    it "last_name" do
      expect(address.last_name).to eq("Bigg")
    end
  end

  context "validation" do
    let(:country) { create :country, states_required: true }
    let(:state) { create :state, name: 'maryland', abbr: 'md', country: country }
    let(:address) { build(:address, country: country) }

    context 'state validation' do
      let(:state_validator) { instance_spy(Spree::Address.state_validator_class) }

      before do
        stub_spree_preferences(use_legacy_address_state_validator: false)
      end

      it "calls the state validator" do
        allow(Spree::Address.state_validator_class).
          to receive(:new).with(address).
          and_return(state_validator)
        expect(state_validator).to receive(:perform)
        address.valid?
      end

      # basic integration test with the validator
      # See address/state_validator_spec for a full address state validation
      # test suite
      it "performs the state validation" do
        address.country.states_required = true
        address.state = nil
        address.state_name = nil
        expect(address.valid?).to eq(false)
        expect(address.errors['state']).to eq(["can't be blank"])
      end

      context 'legacy state validator' do
        before do
          stub_spree_preferences(use_legacy_address_state_validator: true)
        end

        it 'doesnt show deprecation warnings when calling #valid?' do
          expect(Spree::Deprecation).to_not receive(:warn).
            with(/^Spree::Address#state_validate private method has been deprecated/, any_args)
          expect(Spree::Deprecation).to_not receive(:warn).
            with(/^Spree::Address#validate_state_matches_country private method has been deprecated/, any_args)
          address.valid?
        end

        it 'shows the deprecation warnings when calling validation methods directly' do
          expect(Spree::Deprecation).to receive(:warn).
            with(/^Spree::Address#state_validate private method has been deprecated/, any_args)
          address.send(:state_validate)

          expect(Spree::Deprecation).to receive(:warn).
            with(/^Spree::Address#validate_state_matches_country private method has been deprecated/, any_args)
          address.send(:validate_state_matches_country)
        end
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

    context "phone not required" do
      before { stub_spree_preferences(address_requires_phone: false) }

      it "is valid when phone is blank" do
        address.phone = ""
        address.valid?
        expect(address.errors[:phone].size).to eq 0
      end
    end

    context "zipcode not required" do
      before { allow(address).to receive_messages require_zipcode?: false }

      it "shows no errors when zipcode is blank" do
        address.zipcode = ""
        address.valid?
        expect(address.errors[:zipcode]).to be_blank
      end
    end
  end

  context "when creating a record" do
    context "when the `name` field is not explicitly set" do
      subject { build :address, name: nil, firstname: 'John', lastname: 'Doe' }

      it "sets `name` from `firstname` and `lastname`" do
        expect { subject.save }.to change { subject.read_attribute(:name) }.from(nil).to('John Doe')
      end
    end
  end

  context "when updating a record" do
    let(:address) { create(:address, firstname: "John", lastname: "Doe") }

    context "if use_combined_first_and_last_name_in_address is set to false (default)" do
      before do
        allow(Spree::Config).to receive(:use_combined_first_and_last_name_in_address) { false }
      end

      context "and the `name` attribute is not in changeset" do
        it "sets `name` from `firstname` and `lastname`" do
          new_address = described_class.immutable_merge(address, firstname: "Jane", lastname: "Fonda")
          expect(new_address.read_attribute(:name)).to eq("Jane Fonda")
        end
      end

      context "and the `name` attribute is in changeset" do
        it "does not update name" do
          new_address = described_class.immutable_merge(address, name: "Jane Fonda")
          expect(new_address.read_attribute(:name)).to eq("John Von Doe")
        end
      end
    end

    context "if use_combined_first_and_last_name_in_address is set to true" do
      before do
        allow(Spree::Config).to receive(:use_combined_first_and_last_name_in_address) { true }
      end

      context "and the `name` attribute is not in changeset" do
        it "keeps old name" do
          new_address = described_class.immutable_merge(address, firstname: "Jane", lastname: "Fonda")
          expect(new_address.read_attribute(:name)).to eq("John Von Doe")
        end
      end

      context "and the `name` attribute is in changeset" do
        it "updates name" do
          new_address = described_class.immutable_merge(address, name: "Jane Fonda")
          expect(new_address.read_attribute(:name)).to eq("Jane Fonda")
        end
      end
    end
  end

  context ".build_default" do
    context "no user given" do
      let!(:default_country) { create(:country) }

      context 'has a default country' do
        before do
          stub_spree_preferences(default_country_iso: default_country.iso)
        end

        it "sets up a new record with Spree::Config[:default_country_iso]" do
          expect(Spree::Address.build_default.country).to eq default_country
        end

        it 'accepts other attributes' do
          address = Spree::Address.build_default(name: 'Ryan')

          expect(address.country).to eq default_country
          expect(address.name).to eq 'Ryan'
        end

        it 'accepts a block' do
          address = Spree::Address.build_default do |record|
            record.name = 'Ryan'
          end

          expect(address.country).to eq default_country
          expect(address.name).to eq 'Ryan'
        end

        it 'can override the country' do
          another_country = build :country
          address = Spree::Address.build_default(country: another_country)

          expect(address.country).to eq another_country
        end
      end

      # Regression test for https://github.com/spree/spree/issues/1142
      it "raises ActiveRecord::RecordNotFound if :default_country_iso is set to an invalid value" do
        stub_spree_preferences(default_country_iso: "00")
        expect {
          Spree::Address.build_default.country
        }.to raise_error(ActiveRecord::RecordNotFound)
      end
    end
  end

  context '.factory' do
    context 'with attributes that use setters defined in Address' do
      let(:address_attributes) { attributes_for(:address, country_id: nil, country_iso: country.iso) }
      let(:country) { create(:country, iso: 'ZW') }

      it 'uses the setters' do
        expect(described_class.factory(address_attributes).country_id).to eq(country.id)
      end
    end
  end

  context ".immutable_merge" do
    RSpec::Matchers.define :be_address_equivalent_attributes do |expected|
      fields_of_interest = [:firstname, :lastname, :company, :address1, :address2, :city, :zipcode, :phone, :alternative_phone]
      match do |actual|
        expected_attrs = expected.symbolize_keys.slice(*fields_of_interest)
        actual_attrs = actual.symbolize_keys.slice(*fields_of_interest)
        expected_attrs == actual_attrs
      end
    end

    let(:new_address_attributes) { build(:address).attributes }
    subject { Spree::Address.immutable_merge(existing_address, new_address_attributes) }

    context "no existing address supplied" do
      let(:existing_address) { nil }

      context 'and there is not a matching address in the database' do
        it "returns new Address matching attributes given" do
          expect(subject.attributes).to be_address_equivalent_attributes(new_address_attributes)
        end
      end

      context 'and there is a matching address in the database' do
        let(:new_address_attributes) { Spree::Address.value_attributes(matching_address.attributes) }
        let!(:matching_address) { create(:address, name: 'Jordan') }

        it "returns the matching address" do
          expect(subject.attributes).to be_address_equivalent_attributes(new_address_attributes)
          expect(subject.id).to eq(matching_address.id)
        end
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

      context 'and changed address matches an existing address' do
        let(:new_address_attributes) { Spree::Address.value_attributes(matching_address.attributes) }
        let!(:matching_address) { create(:address, name: 'Jordan') }

        it 'returns the matching address' do
          expect(subject.attributes).to be_address_equivalent_attributes(new_address_attributes)
          expect(subject.id).to eq(matching_address.id)
        end
      end
    end
  end

  describe '.value_attributes' do
    subject do
      Spree::Address.value_attributes(base_attributes, merge_attributes)
    end

    context 'with symbols and strings' do
      let(:base_attributes) { { 'address1' => '1234 way', 'address2' => 'apt 2' } }
      let(:merge_attributes) { { address1: '5678 way' } }

      it 'stringifies and merges the keys' do
        expect(subject).to eq('address1' => '5678 way', 'address2' => 'apt 2')
      end
    end

    context 'with database-only attributes' do
      let(:base_attributes) do
        {
          'id' => 1,
          'created_at' => Time.current,
          'updated_at' => Time.current,
          'address1' => '1234 way'
        }
      end
      let(:merge_attributes) do
        {
          'updated_at' => Time.current,
          'address2' => 'apt 2'
        }
      end

      it 'removes the database-only addresses' do
        expect(subject).to eq('address1' => '1234 way', 'address2' => 'apt 2')
      end
    end

    context 'with aliased attributes' do
      let(:base_attributes) { { 'first_name' => 'Jordan' } }
      let(:merge_attributes) { { 'last_name' => 'Brough' } }

      it 'renames them to the normalized value' do
        expect(subject).to eq('firstname' => 'Jordan', 'lastname' => 'Brough', 'name' => 'Jordan Brough')
      end

      it 'does not modify the original hashes' do
        subject
        expect(base_attributes).to eq('first_name' => 'Jordan')
        expect(merge_attributes).to eq('last_name' => 'Brough')
      end
    end
  end

  describe '.taxation_attributes' do
    context 'both taxation and non-taxation attributes are present ' do
      let(:address) { Spree::Address.new name: 'Michael Jackson', state_id: 1, country_id: 2, zipcode: '12345' }

      it 'removes the non-taxation attributes' do
        expect(address.taxation_attributes).not_to eq('name' => 'Michael Jackson')
      end

      it 'returns only the taxation attributes' do
        expect(address.taxation_attributes).to eq('state_id' => 1, 'country_id' => 2, 'zipcode' => '12345')
      end
    end

    context 'taxation attributes are blank' do
      let(:address) { Spree::Address.new name: 'Michael Jackson' }

      it 'returns a subset of the attributes with the correct keys and nil values' do
        expect(address.taxation_attributes).to eq('state_id' => nil, 'country_id' => nil, 'zipcode' => nil)
      end
    end
  end

  context '#country_iso=' do
    let(:address) { build(:address, country_id: nil) }
    let(:country) { create(:country, iso: 'ZW') }

    it 'sets the country to the country with the matching iso code' do
      address.country_iso = country.iso
      expect(address.country_id).to eq(country.id)
    end

    it 'raises an exception if the iso is not found' do
      expect {
        address.country_iso = "NOCOUNTRY"
      }.to raise_error(::ActiveRecord::RecordNotFound, "Couldn't find Spree::Country")
    end
  end

  context '#name' do
    shared_examples 'name attribute' do
      it 'concatenates firstname and lastname' do
        address = described_class.new(firstname: 'Michael J.', lastname: 'Jackson')

        expect(address.name).to eq('Michael J. Jackson')
      end

      it 'returns lastname when firstname is blank' do
        address = described_class.new(firstname: nil, lastname: 'Jackson')

        expect(address.name).to eq('Jackson')
      end

      it 'returns firstanme when lastname is blank' do
        address = described_class.new(firstname: 'Michael J.', lastname: nil)

        expect(address.name).to eq('Michael J.')
      end

      it 'returns empty string when firstname and lastname are blank' do
        address = described_class.new(firstname: nil, lastname: nil)

        expect(address.name).to eq('')
      end

      it 'is included in json representation' do
        address = described_class.new(name: 'Jane Von Doe')

        expect(address.as_json).to include('name' => 'Jane Von Doe')
      end
    end

    context 'when preference `use_combined_first_and_last_name_in_address` is true' do
      it_behaves_like 'name attribute'
    end

    context 'when preference `use_combined_first_and_last_name_in_address` is false' do
      before do
        stub_spree_preferences(use_combined_first_and_last_name_in_address: false)
        allow(Spree::Deprecation).to receive(:warn).with(/firstname|lastname/, any_args)
      end

      it_behaves_like 'name attribute'
    end
  end

  context '#state_text' do
    context 'state is blank' do
      let(:address) { Spree::Address.new state: nil, state_name: 'virginia' }
      specify { expect(address.state_text).to eq('virginia') }
    end

    context 'both name and abbr is present' do
      let(:state) { Spree::State.new name: 'virginia', abbr: 'va' }
      let(:address) { Spree::Address.new state: state }
      specify { expect(address.state_text).to eq('va') }
    end

    context 'only name is present' do
      let(:state) { Spree::State.new name: 'virginia', abbr: nil }
      let(:address) { Spree::Address.new state: state }
      specify { expect(address.state_text).to eq('virginia') }
    end
  end

  context '#requires_phone' do
    subject { described_class.new }

    it { is_expected.to be_require_phone }
  end

  context 'deprecations' do
    let(:address) { described_class.new }

    describe 'json representation' do
      context 'when preference `use_combined_first_and_last_name_in_address` is true' do
        it 'contains `name` but does not contain deprecated fields' do
          expect(address.as_json).not_to include('firstname', 'lastname')
          expect(address.as_json).to include('name')
        end
      end

      context 'when preference `use_combined_first_and_last_name_in_address` is false' do
        before do
          stub_spree_preferences(use_combined_first_and_last_name_in_address: false)
          allow(Spree::Deprecation).to receive(:warn).with(/firstname|lastname/, any_args)
        end

        it 'contains both deprecated fields and `name`' do
          expect(address.as_json).to include('firstname', 'lastname', 'name')
        end
      end
    end

    specify 'firstname is deprecated' do
      expect(Spree::Deprecation).to receive(:warn).with(/firstname/, any_args)

      address.firstname
    end

    specify 'lastname is deprecated' do
      expect(Spree::Deprecation).to receive(:warn).with(/lastname/, any_args)

      address.lastname
    end

    specify 'full_name is deprecated' do
      expect(Spree::Deprecation).to receive(:warn).with(/full_name/, any_args)

      address.full_name
    end
  end

  describe '==' do
    context 'when first address has same name (virtual or not) as the second' do
      let(:first_address) { build(:address, name: 'Mary Jane Watson') }
      let(:second_address) { build(:address, name: nil, firstname: 'Mary Jane', lastname: 'Watson', zipcode: first_address.zipcode) }

      context 'when firstname and lastname do not match' do
        context 'when the preference `use_combined_first_and_last_name_in_address` is true' do
          it 'they are still considered equals' do
            expect(first_address.name).to eq(second_address.name)
            expect(first_address).to eq(second_address)
          end
        end

        context 'when the preference `use_combined_first_and_last_name_in_address` is false' do
          before { stub_spree_preferences(use_combined_first_and_last_name_in_address: false) }

          # This seems to be the most sensible behavior, as if we're not combining attributes,
          # firstname and lastname should be accounted for when checking equality.
          it 'they are not considered equals' do
            expect(first_address.name).to eq(second_address.name)
            expect(first_address).not_to eq(second_address)
          end
        end
      end
    end
  end
end
