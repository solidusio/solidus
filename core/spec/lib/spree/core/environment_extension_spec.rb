require 'spec_helper'

class DummyClass
  include Spree::Core::EnvironmentExtension
end

class C1; end
class C2; end
class C3; end

describe Spree::Core::EnvironmentExtension do
  subject { DummyClass.new }

  before { subject.add_class('random_name') }

  describe 'Basis' do
    it { respond_to?(:random_name) }
    it { respond_to?(:random_name=) }
  end

  describe '#getter' do
    it { expect(subject.random_name).to be_empty }
    it { expect(subject.random_name).to be_kind_of Spree::Core::ClassConstantizer::Set }
  end

  describe '#setter' do
    before { subject.random_name = [C1, C2]; @set = subject.random_name.to_a }

    it { expect(@set).to include(C1) }
    it { expect(@set).to include(C2) }
    it { expect(@set).not_to include(C3) }
  end
end
