RSpec.shared_examples_for 'a taxable item' do
  it { is_expected.to respond_to(:discounted_amount) }
  it { is_expected.to respond_to(:included_tax_total) }
  it { is_expected.to respond_to(:included_tax_total=) }
  it { is_expected.to respond_to(:additional_tax_total) }
  it { is_expected.to respond_to(:additional_tax_total=) }
  it { is_expected.to respond_to(:adjustment_total) }
  it { is_expected.to respond_to(:adjustment_total=) }
  it { is_expected.to respond_to(:promo_total) }
  it { is_expected.to respond_to(:promo_total=) }
  it { is_expected.to respond_to(:pre_tax_amount) }
  it { is_expected.to respond_to(:pre_tax_amount=) }

  # TODO: taxable items should not need a pre tax amount column
  # as amount - included_tax_total should always == pre_tax_amount.
  # However, TaxRate.set_pre_tax_amount needs this.
  it "also has a pre tax amount column " do
    expect(subject.class.column_names).to include("pre_tax_amount")
  end
  it { is_expected.to respond_to(:tax_category) }
  it { is_expected.to respond_to(:adjustments) }
end
