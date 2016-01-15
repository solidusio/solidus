require 'spec_helper'

module Spree
  describe Spree::OrdersHelper, type: :helper do
    context "link_to_tracking" do
      it "returns tracking link if available" do
        a = link_to_tracking_html(shipping_method: true, tracking: '123', tracking_url: 'http://g.c/?t=123').css('a')

        expect(a.text).to eq '123'
        expect(a.attr('href').value).to eq 'http://g.c/?t=123'
      end

      it "returns tracking without link if link unavailable" do
        html = link_to_tracking_html(shipping_method: true, tracking: '123', tracking_url: nil)
        expect(html.css('span').text).to eq '123'
      end

      it "returns nothing when no shipping method" do
        html = link_to_tracking_html(shipping_method: nil, tracking: '123')
        expect(html.css('span').text).to eq ''
      end

      it "returns nothing when no tracking" do
        html = link_to_tracking_html(tracking: nil)
        expect(html.css('span').text).to eq ''
      end

      def link_to_tracking_html(options = {})
        node = link_to_tracking(double(:shipment, options))
        Nokogiri::HTML(node.to_s)
      end
    end
  end
end
