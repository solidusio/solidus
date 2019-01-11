module Spree
  class CountryListPresenter < Spree::Presenter::Delegated
    def initialize(subject)
      subject = prepare_countries(subject)

      super
    end

    protected

    def prepare_countries(countries)
      countries.map { |country| Spree::CountryPresenter.new(country) }.sort_by { |c| c.name.parameterize }
    end
  end
end
