require 'spec_helper'

describe Spree::Admin::ReimbursementsHelper, type: :helper do
  describe '.reimbursement_status_color' do
    subject { helper.reimbursement_status_color(reimbursement) }

    let(:reimbursement) do
      Spree::Reimbursement.new(reimbursement_status: status)
    end

    context 'when status is reimbursed' do
      let(:status) { 'reimbursed' }
      it { is_expected.to eq 'success' }
    end

    context 'when status is pending' do
      let(:status) { 'pending' }
      it { is_expected.to eq 'notice' }
    end

    context 'when status is pending' do
      let(:status) { 'errored' }
      it { is_expected.to eq 'error' }
    end

    context 'when status is not valid' do
      let(:status) { 'noop' }

      it 'should raise an error' do
        expect{ subject }.to raise_error(RuntimeError, "unknown reimbursement status: noop")
      end
    end
  end
end
