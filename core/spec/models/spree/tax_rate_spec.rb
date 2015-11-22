require 'spec_helper'

describe Spree::TaxRate, :type => :model do
  context ".match" do
    let(:order) { create(:order) }
    let(:country) { create(:country) }
    let(:tax_category) { create(:tax_category) }
    let(:calculator) { Spree::Calculator::FlatRate.new }

    subject(:tax_rates_for_order) { Spree::TaxRate.match(order.tax_zone) }

    it "should return an empty array when tax_zone is nil" do
      allow(order).to receive_messages :tax_zone => nil
      expect(tax_rates_for_order).to eq([])
    end

    context "when no rate zones match the tax zone" do
      before do
        Spree::TaxRate.create(:amount => 1, :zone => create(:zone))
      end

      context "when there is no default tax zone" do
        before do
          @zone = create(:zone, :name => "Country Zone", :default_tax => false, :zone_members => [])
          @zone.zone_members.create(:zoneable => country)
        end

        it "should return an empty array" do
          allow(order).to receive_messages :tax_zone => @zone
          expect(tax_rates_for_order).to eq([])
        end

        it "should return the rate that matches the rate zone" do
          rate = Spree::TaxRate.create(
            :amount => 1,
            :zone => @zone,
            :tax_category => tax_category,
            :calculator => calculator
          )

          allow(order).to receive_messages :tax_zone => @zone
          expect(tax_rates_for_order).to eq([rate])
        end

        it "should return all rates that match the rate zone" do
          rate1 = Spree::TaxRate.create(
            :amount => 1,
            :zone => @zone,
            :tax_category => tax_category,
            :calculator => calculator
          )

          rate2 = Spree::TaxRate.create(
            :amount => 2,
            :zone => @zone,
            :tax_category => tax_category,
            :calculator => Spree::Calculator::FlatRate.new
          )

          allow(order).to receive_messages :tax_zone => @zone
          expect(tax_rates_for_order).to match_array([rate1, rate2])
        end

        context "when the tax_zone is contained within a rate zone" do
          before do
            sub_zone = create(:zone, :name => "State Zone", :zone_members => [])
            sub_zone.zone_members.create(:zoneable => create(:state, :country => country))
            allow(order).to receive_messages :tax_zone => sub_zone
            @rate = Spree::TaxRate.create(
              :amount => 1,
              :zone => @zone,
              :tax_category => tax_category,
              :calculator => calculator
            )
          end

          it "should return the rate zone" do
            expect(tax_rates_for_order).to eq([@rate])
          end
        end
      end

      context "when there is a default tax zone" do
        before do
          @zone = create(:zone, :name => "Country Zone", :default_tax => true, :zone_members => [])
          @zone.zone_members.create(:zoneable => country)
        end

        let(:included_in_price) { false }
        let!(:rate) do
          Spree::TaxRate.create(:amount => 1,
                                :zone => @zone,
                                :tax_category => tax_category,
                                :calculator => calculator,
                                :included_in_price => included_in_price)
        end

        context "when the order has the same tax zone" do
          before do
            allow(order).to receive_messages :tax_zone => @zone
            allow(order).to receive_messages :tax_address => tax_address
          end

          let(:tax_address) { stub_model(Spree::Address) }

          context "when the tax is not a VAT" do
            it { is_expected.to eq([rate]) }
          end

          context "when the tax is a VAT" do
            let(:included_in_price) { true }
            it { is_expected.to eq([rate]) }
          end
        end

        context "when the order has a different tax zone" do
          before do
            allow(order).to receive_messages :tax_zone => create(:zone, :name => "Other Zone")
            allow(order).to receive_messages :tax_address => tax_address
          end

          context "when the order has a tax_address" do
            let(:tax_address) { stub_model(Spree::Address) }

            context "when the tax is not VAT" do
              it "returns no tax rate" do
                expect(subject).to be_empty
              end
            end
          end

          context "when the order does not have a tax_address" do
            let(:tax_address) { nil}

            context "when the tax is not a VAT" do
              it { is_expected.to be_empty }
            end
          end
        end
      end
    end
  end

  context ".adjust" do
    let!(:country) { create(:country) }
    let!(:taxables_category) { create(:tax_category, name: "Taxable Foo") }
    let!(:non_taxables_category) { create(:tax_category, name: "Non Taxable") }
    let!(:zone) { create(:zone, countries: [country]) }
    let!(:rate1) do
      create(
        :tax_rate,
        tax_category: taxables_category,
        zone: zone,
        amount: 0.1
      )
    end
    let!(:rate2) do
      create(
        :tax_rate,
        tax_category: taxables_category,
        zone: zone,
        amount: 0.05
      )
    end
    let(:taxable) { create(:product, tax_category: taxables_category) }
    let(:non_taxable) { create(:product, tax_category: non_taxables_category) }
    let!(:order) { Spree::Order.create! }
    let(:line_item) { order.line_items.last }

    subject(:adjust_order_items) { Spree::TaxRate.adjust(order.tax_zone, order.line_items) }

    context "with shipments" do
      let(:shipments) do
        [stub_model(Spree::Shipment, cost: 10.0, tax_category: taxables_category)]
      end

      let!(:rate2) do
        create(
          :tax_rate,
          tax_category: non_taxables_category,
          zone: zone,
          amount: 0.05
        )
      end

      before do
        allow(Spree::TaxRate).to receive(:for_zone).and_return([rate1, rate2])
      end

      it "should apply adjustments for two tax rates to the order" do
        expect(rate1).to receive(:adjust)
        expect(rate2).not_to receive(:adjust)
        Spree::TaxRate.adjust(zone, shipments)
      end
    end

    context "not taxable line item " do
      before { order.contents.add(non_taxable.master, 1) }

      context "with order having no zone" do
        before { allow(order).to receive(:tax_zone).and_return(nil) }

        it "should not create a tax adjustment" do
          expect(line_item.adjustments.tax.charge.count).to eq(0)
          expect { adjust_order_items }.not_to change { line_item.adjustments.tax.charge.count }
        end

        it "should not create a refund" do
          expect(line_item.adjustments.credit.count).to eq(0)
          expect { adjust_order_items }.not_to change { line_item.adjustments.tax.charge.count }
        end
      end

      context "with order tax zone being the tax rate's zone" do
        before { allow(order).to receive(:tax_zone).and_return(zone) }

        it "should not create a tax adjustment" do
          expect(line_item.adjustments.tax.charge.count).to eq(0)
          expect { adjust_order_items }.not_to change { line_item.adjustments.tax.charge.count }
        end

        it "should not create a refund" do
          expect(line_item.adjustments.credit.count).to eq(0)
          expect { adjust_order_items }.not_to change { line_item.adjustments.tax.charge.count }
        end
      end
    end

    context "taxable line item" do
      before do
        order.contents.add(taxable.master, 1)
        # Delete all adjustments created when adding an item so we can observe
        # changes.
        line_item.adjustments.destroy_all
      end

      context "when price includes tax" do
        let!(:default_zone) { create(:zone, countries: [country], default_tax: true) }

        let!(:rate1) do
          create(
            :tax_rate,
            tax_category: taxables_category,
            zone: zone,
            amount: 0.1,
            included_in_price: true
          )
        end
        let!(:rate2) do
          create(
            :tax_rate,
            tax_category: taxables_category,
            zone: zone,
            amount: 0.05,
            included_in_price: true
          )
        end

        context "when order's zone is the default zone" do
          let!(:zone) { default_zone }

          it "should create two adjustments, one for each tax rate" do
            expect(line_item.adjustments.credit.count).to eq(0)
            expect { adjust_order_items }.to change { line_item.adjustments.tax.count }.by(2)
          end

          it "should not create a tax refund" do
            expect(line_item.adjustments.credit.count).to eq(0)
            expect { adjust_order_items }.not_to change { line_item.adjustments.tax.credit.count }
          end

          # This does not work either. Both tax rates should be taken into account.
          it "price adjustments should be accurate" do
            expect { adjust_order_items }.to change { line_item.adjustments.tax.count }
            included_tax = line_item.adjustments.sum(:amount)
            expect(line_item.pre_tax_amount).to eq(17.38)
            expect(line_item.pre_tax_amount + included_tax).to eq(line_item.price)
          end
        end

        context "when order's zone is nil" do
          before do
            allow(order).to receive(:tax_zone).and_return(nil)
          end

          it "should create no adjustments" do
            expect(line_item.adjustments.credit.count).to eq(0)
            expect { adjust_order_items }.not_to change { line_item.adjustments.tax.count }
          end
        end

        context "when order's zone is another zone" do
          let(:foreign_country) { create(:country) }
          let(:foreign_zone) { create(:zone, countries: [foreign_country]) }

          before do
            allow(order).to receive(:tax_zone).and_return(foreign_zone)
          end

          context "and the foreign zone has VAT rates" do
            let!(:foreign_vat) do
              create(
              :tax_rate,
              included_in_price: true,
              tax_category: taxables_category,
              zone: foreign_zone,
              amount: 0.21
              )
            end

            it "applies the foreign VAT" do
              expect(line_item.adjustments.credit.count).to eq(0)
              expect { adjust_order_items }.to change { line_item.adjustments.tax.count }.by(1)
            end

            it "does not refund the default zone's VAT" do
              expect(line_item.adjustments.credit.count).to eq(0)
              expect { adjust_order_items }.not_to change { line_item.adjustments.credit.count }
            end
          end

          context "and the foreign zone does not have VAT rates" do
            # This does not work. The code removes a VAT rate if
            # there's more than one VAT of the same category.
            it "refunds both default zone's VATs" do
              expect(line_item.adjustments.count).to eq(0)
              expect { adjust_order_items }.to change { line_item.adjustments.tax.count }.by(2)
            end
          end
        end
      end

      context "when price does not include tax" do
        before do
          allow(order).to receive(:tax_zone).and_return(zone)
          adjust_order_items
        end

        it "should delete adjustments for open order when taxrate is deleted" do
          rate1.destroy!
          rate2.destroy!
          expect(line_item.adjustments.count).to eq(0)
        end

        it "should not delete adjustments for complete order when taxrate is deleted" do
          order.update_column :completed_at, Time.now
          rate1.destroy!
          rate2.destroy!
          expect(line_item.adjustments.count).to eq(2)
        end

        it "should create two adjustments" do
          expect(line_item.adjustments.count).to eq(2)
        end

        it "should not create a tax refund" do
          expect(line_item.adjustments.credit.count).to eq(0)
        end

        describe 'tax adjustments' do
          it "should apply adjustments when a tax zone is present" do
            expect(line_item.adjustments.count).to eq(2)
          end

          describe "when the order's tax zone is nil" do
            before { allow(order).to receive(:tax_zone).and_return(nil) }

            it 'does not apply any adjustments' do
              Spree::TaxRate.adjust(order.tax_zone, order.line_items)
              expect(line_item.adjustments.count).to eq(0)
            end
          end
        end
      end
    end
  end
end
