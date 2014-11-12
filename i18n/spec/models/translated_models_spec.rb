module Spree
  RSpec.describe Product, type: :model do
    include_context "behaves as translatable"
  end

  RSpec.describe OptionType, type: :model do
    include_context "behaves as translatable"
  end

  RSpec.describe Taxon, type: :model do
    include_context "behaves as translatable"
  end

  RSpec.describe Taxonomy, type: :model do
    include_context "behaves as translatable"
  end

  RSpec.describe Promotion, type: :model do
    include_context "behaves as translatable"
  end

  RSpec.describe Property, type: :model do
    include_context "behaves as translatable"
  end

  RSpec.describe ProductProperty, type: :model do
    include_context "behaves as translatable"
  end
end
