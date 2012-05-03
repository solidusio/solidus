# coding: utf-8

require 'spec_helper'

describe "Japanese (ja) translations" do
  describe "spree_api.yml" do
    subject { "config/locales/ja/spree_api.yml" }
    it { subject.should be_a_subset_of("default/spree_api.yml") }
    it { subject.should be_a_complete_translation_of("default/spree_api.yml") }
    it { subject.should be_a_thorough_translation_of("default/spree_api.yml").except([]) }
  end
  
  describe "spree_auth.yml" do
    subject { "config/locales/ja/spree_auth.yml" }
    it { subject.should be_a_subset_of("default/spree_auth.yml") }
    it { subject.should be_a_complete_translation_of("default/spree_auth.yml") }
    it { subject.should be_a_thorough_translation_of("default/spree_auth.yml").except([]) }
  end
  
  describe "spree_core.yml" do
    subject { "config/locales/ja/spree_core.yml" }
    let(:untranslated_keys) do
      [ 
        "activerecord.attributes.spree/country.iso",
        "activerecord.attributes.spree/country.iso3",
        "backordering_is_allowed",
        "pagination.truncate",
        "powered_by",
        "products_with_zero_inventory_display",
        "smtp",
        "spree.date_picker.format",
        "views.pagination.truncate"
      ]
    end
    
    it { subject.should be_a_subset_of("default/spree_core.yml") }

    it do
      subject.should be_a_thorough_translation_of("default/spree_core.yml").
        except(untranslated_keys)
    end

    it do
      I18n.backend = I18n::Backend::Simple.new
      I18n.backend.load_translations("config/locales/ja/spree_core.rb")
      I18n.backend.load_translations("config/locales/ja/spree_core.yml")
      I18n.locale = "ja"
      I18n.t("backordering_is_allowed", :not => "").should == "取り寄せ可"
      I18n.t("backordering_is_allowed", :not => I18n.t("not")).should == "取り寄せ不可"
      I18n.t("products_with_zero_inventory_display", :not => "").should == "在庫なしの商品が表示されます"
      I18n.t("products_with_zero_inventory_display", :not => I18n.t("not")).should == "在庫なしの商品は表示されません"
    end
  end
  
  describe "spree_dash.yml" do
    subject { "config/locales/ja/spree_dash.yml" }
    it { subject.should be_a_subset_of("default/spree_dash.yml") }
    it { subject.should be_a_complete_translation_of("default/spree_dash.yml") }
    it { subject.should be_a_thorough_translation_of("default/spree_dash.yml").except([]) }
  end
  
  describe "spree_promo.yml" do
    subject { "config/locales/ja/spree_promo.yml" }
    it { subject.should be_a_subset_of("default/spree_promo.yml") }
    it { subject.should be_a_complete_translation_of("default/spree_promo.yml") }
    it { subject.should be_a_thorough_translation_of("default/spree_promo.yml").except([]) }
  end
end
