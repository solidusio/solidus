# coding: utf-8

{
  "ja" => {
    "backordering_is_allowed" => lambda { |_, options|
      options[:not] == "" ? "取り寄せ可" : "取り寄せ不可"
    },
    "products_with_zero_inventory_display" => lambda { |_, options|
      if options[:not] == ""
        "在庫なしの商品が表示されます"
      else
        "在庫なしの商品は表示されません"
      end
    }
  }
}
