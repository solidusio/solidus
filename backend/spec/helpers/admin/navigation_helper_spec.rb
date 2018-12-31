# frozen_string_literal: true

require 'spec_helper'

describe Spree::Admin::NavigationHelper, type: :helper do
  describe "#tab" do
    context "creating an admin tab" do
      it "should capitalize the first letter of each word in the tab's label" do
        admin_tab = helper.tab(:orders)
        expect(admin_tab).to include("Orders")
      end
    end

    describe "selection" do
      context "when match_path option is not supplied" do
        subject(:tab) { helper.tab(:orders) }

        it "should be selected if the controller matches" do
          allow(controller).to receive(:controller_name).and_return("orders")
          expect(subject).to include('class="selected"')
        end

        it "should not be selected if the controller does not match" do
          allow(controller).to receive(:controller_name).and_return("bonobos")
          expect(subject).not_to include('class="selected"')
        end

        it "should be selected if the current path" do
          allow(helper).to receive(:request).and_return(double(ActionDispatch::Request, fullpath: "/admin/orders"))
          expect(subject).to include('class="selected"')
        end

        it "should not be selected if not current path" do
          allow(helper).to receive(:request).and_return(double(ActionDispatch::Request, fullpath: "/admin/products"))
          expect(subject).not_to include('class="selected"')
        end
      end

      context "when match_path option is supplied" do
        before do
          allow(helper).to receive(:request).and_return(double(ActionDispatch::Request, fullpath: "/admin/orders/edit/1"))
        end

        it "should be selected if the fullpath matches" do
          allow(controller).to receive(:controller_name).and_return("bonobos")
          tab = helper.tab(:orders, match_path: '/orders')
          expect(tab).to include('class="selected"')
        end

        it "should be selected if the fullpath matches a regular expression" do
          allow(controller).to receive(:controller_name).and_return("bonobos")
          tab = helper.tab(:orders, match_path: /orders$|orders\//)
          expect(tab).to include('class="selected"')
        end

        it "should not be selected if the fullpath does not match" do
          allow(controller).to receive(:controller_name).and_return("bonobos")
          tab = helper.tab(:orders, match_path: '/shady')
          expect(tab).not_to include('class="selected"')
        end

        it "should not be selected if the fullpath does not match a regular expression" do
          allow(controller).to receive(:controller_name).and_return("bonobos")
          tab = helper.tab(:orders, match_path: /shady$|shady\//)
          expect(tab).not_to include('class="selected"')
        end
      end
    end

    it "should accept a block of content to append" do
      admin_tab = helper.tab(:orders){ 'foo' }
      expect(admin_tab).to end_with("foo</li>")
    end
  end

  describe "#link_to_delete" do
    let!(:item) { create(:stock_item) }
    let(:options) { {} }
    let(:link) { subject }

    subject { helper.link_to_delete(item, options) }

    # object_url is provided by the ResourceController abstract controller.
    # as we cannot set a custom controller for helper tests, we need to fake it
    before do
      without_partial_double_verification do
        allow(helper).to receive(:object_url) do |o|
          "/stock_items/#{o.to_param}"
        end
      end
    end

    it "generates a deletion link for the resource" do
      expect(link).to include("href=\"/stock_items/#{item.to_param}\"")
      expect(link).to include("data-action=\"remove\"")
      expect(link).to include("data-confirm=\"Are you sure?\"")
      expect(link).to include("<span class=\"text\">Delete</span>")
    end

    it "allows customization of the url" do
      options[:url] = "/test/url"
      expect(link).to include("href=\"/test/url\"")
    end

    it "allows customization of the link name" do
      options[:name] = "Delete Item"
      expect(link).to include("name=\"Delete Item\"")
      expect(link).to include("<span class=\"text\">Delete Item</span>")
    end

    it "allows customization of the confirmation message" do
      options[:confirm] = "Please confirm."
      expect(link).to include("data-confirm=\"Please confirm.\"")
    end
  end

  describe "#solidus_icon" do
    context "if given an icon_name" do
      subject(:solidus_icon) { helper.solidus_icon('example-icon-name') }

      it { is_expected.to eq "<i class=\"example-icon-name\"></i>" }
    end

    context "if not given nil icon_name" do
      subject(:solidus_icon) { helper.solidus_icon(nil) }

      it { is_expected.to eq "" }
    end
  end

  describe "#icon" do
    subject(:icon) { helper.icon('icon-name') }

    it "is a deprecated way to use #solidus_icon" do
      expect(Spree::Deprecation).to receive(:warn).with("icon is deprecated and will be removed from Solidus 3.0 (use solidus_icon instead)", instance_of(Array))
      expect(subject).to eq helper.solidus_icon('icon-name')
    end
  end
end
