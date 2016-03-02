namespace :solidus do
  namespace :upgrade do
    desc "Upgrade Solidus to version 1.3"
    task one_point_three: [
        'solidus:migrations:assure_store_on_orders:up'
      ] do
      puts "Your Solidus install is ready for Solidus 1.3."
    end
  end
end
