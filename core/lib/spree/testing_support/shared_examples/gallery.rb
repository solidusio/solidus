shared_examples_for 'is a gallery' do

  describe '#images' do
    subject { gallery.images }

    it 'behaves like an enumerable' do
      # in rails 5 a CollectionProxy is enumerable and we can
      # switch to is_a? Enumerable as the docs specify it should be
      [:[], :each, :reduce].each do |enum_method|
        expect(subject).to respond_to enum_method
      end
    end
  end

  [:best_image, :primary_image].each do |gallery_method|
    subject { gallery }
    it { is_expected.to respond_to gallery_method }
  end

  it 'has a class method to return an array for preload_params' do
    expect(gallery.class.preload_params).to be_a Array
  end
end
