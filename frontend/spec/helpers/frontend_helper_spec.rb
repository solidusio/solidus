require 'spec_helper'

module Spree
  describe FrontendHelper, type: :helper do
    let(:current_store){ create :store }

    # Regression test for https://github.com/spree/spree/issues/2034
    context "flash_message" do
      let(:flash) { {"notice" => "ok", "foo" => "foo", "bar" => "bar"} }

      it "should output all flash content" do
        flash_messages
        html = Nokogiri::HTML(helper.output_buffer)
        expect(html.css(".notice").text).to eq("ok")
        expect(html.css(".foo").text).to eq("foo")
        expect(html.css(".bar").text).to eq("bar")
      end

      it "should output flash content except one key" do
        flash_messages(:ignore_types => :bar)
        html = Nokogiri::HTML(helper.output_buffer)
        expect(html.css(".notice").text).to eq("ok")
        expect(html.css(".foo").text).to eq("foo")
        expect(html.css(".bar").text).to be_empty
      end

      it "should output flash content except some keys" do
        flash_messages(:ignore_types => [:foo, :bar])
        html = Nokogiri::HTML(helper.output_buffer)
        expect(html.css(".notice").text).to eq("ok")
        expect(html.css(".foo").text).to be_empty
        expect(html.css(".bar").text).to be_empty
        expect(helper.output_buffer).to eq("<div class=\"flash notice\">ok</div>")
      end
    end

    # Regression test for https://github.com/spree/spree/issues/2759
    it "nested_taxons_path works with a Taxon object" do
      taxon = create(:taxon, :name => "iphone")
      expect(spree.nested_taxons_path(taxon)).to eq("/t/iphone")
    end

    # Regression test for https://github.com/spree/spree/issues/2396
    context "meta_data_tags" do
      it "truncates a product description to 160 characters" do
        # Because the controller_name method returns "test"
        # controller_name is used by this method to infer what it is supposed
        # to be generating meta_data_tags for
        text = Faker::Lorem.paragraphs(2).join(" ")
        @test = Spree::Product.new(:description => text)
        tags = Nokogiri::HTML.parse(meta_data_tags)
        content = tags.css("meta[name=description]").first["content"]
        assert content.length <= 160, "content length is not truncated to 160 characters"
      end
    end
  end
end
