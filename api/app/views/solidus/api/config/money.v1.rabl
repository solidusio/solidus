object false
node(:symbol) { ::Money.new(1, Solidus::Config[:currency]).symbol }
