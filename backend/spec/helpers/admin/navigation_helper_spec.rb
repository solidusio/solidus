# coding: UTF-8
require 'spec_helper'

describe Spree::Admin::NavigationHelper, type: :helper do
  describe "#tab" do
    context "creating an admin tab" do
      it "should capitalize the first letter of each word in the tab's label" do
        admin_tab = helper.tab(:orders)
        expect(admin_tab).to include("Orders")
      end
    end

    it "should accept options with label and capitalize each word of it" do
      admin_tab = helper.tab(:orders, label: "delivered orders")
      expect(admin_tab).to include("Delivered Orders")
    end

    it "should capitalize words with unicode characters" do
      # overview
      admin_tab = helper.tab(:orders, label: "přehled")
      expect(admin_tab).to include("Přehled")
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
      end

      context "when match_path option is supplied" do
        before do
          allow(helper).to receive(:admin_path).and_return("/somepath")
          allow(helper).to receive(:request).and_return(double(ActionDispatch::Request, fullpath: "/somepath/orders/edit/1"))
        end

        it "should be selected if the fullpath matches" do
          allow(controller).to receive(:controller_name).and_return("bonobos")
          tab = helper.tab(:orders, label: "delivered orders", match_path: '/orders')
          expect(tab).to include('class="selected"')
        end

        it "should be selected if the fullpath matches a regular expression" do
          allow(controller).to receive(:controller_name).and_return("bonobos")
          tab = helper.tab(:orders, label: "delivered orders", match_path: /orders$|orders\//)
          expect(tab).to include('class="selected"')
        end

        it "should not be selected if the fullpath does not match" do
          allow(controller).to receive(:controller_name).and_return("bonobos")
          tab = helper.tab(:orders, label: "delivered orders", match_path: '/shady')
          expect(tab).not_to include('class="selected"')
        end

        it "should not be selected if the fullpath does not match a regular expression" do
          allow(controller).to receive(:controller_name).and_return("bonobos")
          tab = helper.tab(:orders, label: "delivered orders", match_path: /shady$|shady\//)
          expect(tab).not_to include('class="selected"')
        end
      end
    end

    it "should accept a block of content to append" do
      admin_tab = helper.tab(:orders){ 'foo' }
      expect(admin_tab).to end_with("foo</li>")
    end
  end
end
