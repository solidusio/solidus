Rails.application.config.spree.add_class("reports")
Rails.application.config.spree.reports << Spree::Report::SalesTotal
Rails.application.config.spree.reports << Spree::Report::OutOfStockVariants
