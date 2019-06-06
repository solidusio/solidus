# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Spree::BaseHelper, type: :helper do
  include Spree::BaseHelper

  let(:current_store){ create :store }

  context "available_countries" do
    let(:country) { create(:country) }

    before do
      3.times { create(:country) }
    end

    context "with no checkout zone defined" do
      before do
        stub_spree_preferences(checkout_zone: nil)
      end

      it "return complete list of countries" do
        expect(available_countries.count).to eq(Spree::Country.count)
      end

      it "uses locales for country names" do
        expect(available_countries).to include(having_attributes(name: "United States of America"))
      end
    end

    context "with a checkout zone defined" do
      context "checkout zone is of type country" do
        before do
          @country_zone = create(:zone, name: "CountryZone")
          @country_zone.members.create(zoneable: country)
          stub_spree_preferences(checkout_zone: @country_zone.name)
        end

        it "return only the countries defined by the checkout zone" do
          expect(available_countries).to eq([country])
        end

        it "returns only the countries defined by the checkout zone passed as parameter" do
          expect(available_countries(restrict_to_zone: @country_zone.name)).to eq([country])
        end
      end

      context "checkout zone is of type state" do
        before do
          state_zone = create(:zone, name: "StateZone")
          state = create(:state, country: country)
          state_zone.members.create(zoneable: state)
          stub_spree_preferences(checkout_zone: state_zone.name)
        end

        it "return complete list of countries" do
          expect(available_countries.count).to eq(Spree::Country.count)
        end
      end
    end
  end

  # Regression test for https://github.com/spree/spree/issues/2034
  context "flash_message" do
    let(:flash) { { "notice" => "ok", "foo" => "foo", "bar" => "bar" } }

    it "should output all flash content" do
      flash_messages
      html = Nokogiri::HTML(helper.output_buffer)
      expect(html.css(".notice").text).to eq("ok")
      expect(html.css(".foo").text).to eq("foo")
      expect(html.css(".bar").text).to eq("bar")
    end

    it "should output flash content except one key" do
      flash_messages(ignore_types: :bar)
      html = Nokogiri::HTML(helper.output_buffer)
      expect(html.css(".notice").text).to eq("ok")
      expect(html.css(".foo").text).to eq("foo")
      expect(html.css(".bar").text).to be_empty
    end

    it "should output flash content except some keys" do
      flash_messages(ignore_types: [:foo, :bar])
      html = Nokogiri::HTML(helper.output_buffer)
      expect(html.css(".notice").text).to eq("ok")
      expect(html.css(".foo").text).to be_empty
      expect(html.css(".bar").text).to be_empty
      expect(helper.output_buffer).to eq("<div class=\"flash notice\">ok</div>")
    end
  end

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

  # Regression test for https://github.com/spree/spree/issues/2396
  context "meta_data_tags" do
    it "truncates a product description to 160 characters" do
      # Because the controller_name method returns "test"
      # controller_name is used by this method to infer what it is supposed
      # to be generating meta_data_tags for
      @test = Spree::Product.new(description: "a" * 200)
      tags = Nokogiri::HTML.parse(meta_data_tags)
      content = tags.css("meta[name=description]").first["content"]
      expect(content.length).to be <= 160
    end
  end

  describe "#pretty_time" do
    subject { pretty_time(date) }

    let(:date) { Time.new(2012, 11, 6, 13, 33) }

    it "pretty prints time in long format" do
      is_expected.to eq "November 06, 2012 1:33 PM"
    end

    context 'with format set to short' do
      subject { pretty_time(date, :short) }

      it "pretty prints time in short format" do
        is_expected.to eq "Nov 6 '12 1:33pm"
      end
    end
  end

  context "plural_resource_name" do
    let(:plural_config) { Spree::I18N_GENERIC_PLURAL }
    let(:base_class) { Spree::Product }

    subject { plural_resource_name(base_class) }

    it "should use ActiveModel::Naming module to pluralize model names" do
      expect(subject).to eq base_class.model_name.human(count: plural_config)
    end

    it "should use the Spree::I18N_GENERIC_PLURAL constant" do
      expect(base_class.model_name).to receive(:human).with(hash_including(count: plural_config))
      subject
    end
  end
end
