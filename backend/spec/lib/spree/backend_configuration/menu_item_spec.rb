# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Spree::BackendConfiguration::MenuItem do
  describe '#children' do
    it 'is the replacement for the deprecated #partial method' do
      expect(Spree.deprecator).to receive(:warn).with(a_string_matching(/partial/))

      described_class.new(partial: 'foo')
    end
  end

  describe '#match_path?' do
    it 'matches a string using the admin path prefix' do
      subject = described_class.new(match_path: '/stock_items')
      request = double(ActionDispatch::Request, fullpath: '/admin/stock_items/1/edit')

      expect(subject.match_path?(request)).to be_truthy
    end

    it 'matches a proc accepting the request object' do
      request = double(ActionDispatch::Request, fullpath: '/foo/bar/baz')
      subject = described_class.new(match_path: -> { _1.fullpath.include? '/bar/' })

      expect(subject.match_path?(request)).to be_truthy
    end

    it 'matches a regexp' do
      subject = described_class.new(match_path: %r{/bar/})
      request = double(ActionDispatch::Request, fullpath: '/foo/bar/baz')

      expect(subject.match_path?(request)).to be_truthy
    end

    it 'matches the item url as the fullpath prefix' do
      subject = described_class.new(url: '/foo/bar')
      request = double(ActionDispatch::Request, fullpath: '/foo/bar/baz')

      expect(subject.match_path?(request)).to be_truthy
    end

    it 'matches the item on the (deprecated) sections against the controller name' do
      allow(Spree.deprecator).to receive(:warn).with(a_string_matching(/icon/))
      allow(Spree.deprecator).to receive(:warn).with(a_string_matching(/sections/))

      subject = described_class.new([:foo, :bar], :baz_icon)
      matching_request = double(
        ActionDispatch::Request,
        controller_class: double(ActionController::Base, controller_name: 'bar'),
        fullpath: '/qux',
      )
      other_request = double(
        ActionDispatch::Request,
        controller_class: double(ActionController::Base, controller_name: 'baz'),
        fullpath: '/qux',
      )

      expect(subject.match_path?(matching_request)).to be true
      expect(subject.match_path?(other_request)).to be false
    end
  end

  describe "#url" do
    subject { described_class.new(url: url).url }

    context "if url is a string" do
      let(:url) { "/admin/promotions" }
      it { is_expected.to eq("/admin/promotions") }
    end

    context "when url is a symbol" do
      let(:url) { :admin_promotions_path }
      it "treats it as a route name" do
        is_expected.to eq("/admin/promotions")
      end
    end

    context "if url is a lambda" do
      let(:route_proxy) { double(my_path: "/admin/friendly_promotions") }
      let(:url) { -> { route_proxy.my_path } }

      it { is_expected.to eq("/admin/friendly_promotions") }
    end
  end

  describe "deprecated behavior" do
    describe "passing `sections` and `icon` sequentially" do
      it "warns about the deprecation" do
        expect(Spree.deprecator).to receive(:warn).with(a_string_matching(/sections/))
        expect(Spree.deprecator).to receive(:warn).with(a_string_matching(/icon/))

        described_class.new([:foo, :bar], 'icon')
      end

      it "raises ArgumentError when providing the wrong number of sequential arguments" do
        expect { described_class.new([:foo, :bar], 'icon', 'baz') }.to raise_error(ArgumentError)
        expect { described_class.new([:foo, :bar]) }.to raise_error(ArgumentError)
      end
    end
  end
end
