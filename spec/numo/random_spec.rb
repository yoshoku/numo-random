# frozen_string_literal: true

RSpec.describe Numo::Random do
  it 'has a version number' do
    expect(Numo::Random::VERSION).not_to be_nil
  end

  it 'sets and gets random seed', :aggregate_failures do
    rng = Numo::Random::PCG64.new(seed: 10)
    expect(rng.seed).to eq(10)
    rng.seed = 100
    expect(rng.seed).to eq(100)
  end

  it 'gets random number' do
    rng = Numo::Random::PCG64.new
    expect(rng.random).not_to be_nil
  end

  describe '#normal' do
    subject(:rng) { Numo::Random::PCG64.new(seed: 42) }

    context 'when array type is DFloat' do
      let(:x) { Numo::DFloat.new(500, 200) }
      let(:y) { rng.normal(x) }

      it 'obtains random numbers form a normal distribution', :aggregate_failures do
        expect(y).to be_a(Numo::DFloat)
        expect(y.shape).to match(x.shape)
        expect(y.mean).to be_within(1e-2).of(0)
        expect(y.stddev).to be_within(1e-2).of(1)
      end
    end

    context 'when array type is SFloat' do
      let(:x) { Numo::SFloat.new(500, 200) }
      let(:y) { rng.normal(x) }

      it 'obtains random numbers form a normal distribution', :aggregate_failures do
        expect(y).to be_a(Numo::SFloat)
        expect(y.shape).to match(x.shape)
        expect(y.mean).to be_within(1e-2).of(0)
        expect(y.stddev).to be_within(1e-2).of(1)
      end
    end

    context 'when loc and scale parameters are given' do
      let(:x) { Numo::DFloat.new(500, 200) }
      let(:y) { rng.normal(x, loc: 10, scale: 2) }

      it 'obtains random numbers form a normal distribution along with given parameters', :aggregate_failures do
        expect(y.mean).to be_within(1e-2).of(10)
        expect(y.stddev).to be_within(1e-2).of(2)
      end
    end

    context 'when negative value is given to scale' do
      let(:x) { Numo::DFloat.new(500, 200) }

      it 'raises ArgumentError' do
        expect { rng.normal(x, scale: -100) }.to raise_error(ArgumentError, 'scale must be a non-negative value')
      end
    end

    context 'when array type is Int32' do
      let(:x) { Numo::Int32.new(500, 200) }

      it 'raises TypeError' do
        expect { rng.normal(x) }.to raise_error(TypeError, 'invalid NArray class, it must be DFloat or SFloat')
      end
    end
  end
end
