# coding: utf-8

require 'spec_helper'

describe "Japanese (ja) translations" do
  before do
    I18n.backend = I18n::Backend::Simple.new
    I18n.backend.load_translations("config/locales/ja.rb")
    I18n.backend.load_translations("config/locales/ja.yml")
    I18n.locale = "ja"
  end

  it do
    I18n.t("backordering_is_allowed", :not => "").should == "取り寄せ可"
    I18n.t("backordering_is_allowed", :not => I18n.t("not")).should == "取り寄せ不可"
    I18n.t("products_with_zero_inventory_display", :not => "").should == "在庫なしの商品が表示されます"
    I18n.t("products_with_zero_inventory_display", :not => I18n.t("not")).should == "在庫なしの商品は表示されません"
  end
end
