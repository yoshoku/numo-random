# frozen_string_literal: true

RSpec.describe Numo::Random::Generator do
  subject(:rng) { described_class.new(seed: 42, algorithm: algorithm) }

  let(:algorithm) { 'pcg64' }

  describe '#initialize' do
    context "when algorithm args is 'mt32'" do
      let(:algorithm) { 'mt32' }

      it 'uses MT32 class for random number generator', :aggregate_failures do
        expect(rng.algorithm).to eq('mt32')
        expect(rng.instance_variable_get(:@rng)).to be_a(Numo::Random::MT32)
      end
    end

    context "when algorithm args is 'mt64'" do
      let(:algorithm) { 'mt64' }

      it 'uses MT64 class for random number generator', :aggregate_failures do
        expect(rng.algorithm).to eq('mt64')
        expect(rng.instance_variable_get(:@rng)).to be_a(Numo::Random::MT64)
      end
    end

    context "when algorithm args is 'pcg32'" do
      let(:algorithm) { 'pcg32' }

      it 'uses PCG32 class for random number generator', :aggregate_failures do
        expect(rng.algorithm).to eq('pcg32')
        expect(rng.instance_variable_get(:@rng)).to be_a(Numo::Random::PCG32)
      end
    end

    context "when algorithm args is 'pcg64'" do
      let(:algorithm) { 'pcg64' }

      it 'uses PCG64 class for random number generator', :aggregate_failures do
        expect(rng.algorithm).to eq('pcg64')
        expect(rng.instance_variable_get(:@rng)).to be_a(Numo::Random::PCG64)
      end
    end

    context 'when wrong algorithm args given' do
      let(:algorithm) { 'none' }

      it 'raises ArgumentError' do
        expect { rng }.to raise_error(ArgumentError, "Numo::Random::Generator does not support 'none' algorithm")
      end
    end
  end

  describe '#seed= and #seed' do
    it 'sets and gets random seed', :aggregate_failures do
      expect(rng.seed).to eq(42)
      rng.seed = 100
      expect(rng.seed).to eq(100)
    end
  end

  describe '#random' do
    it 'gets random number' do
      expect(rng.random).not_to be_nil
    end
  end

  describe '#bernoulli' do
    %i[int8 int16 int32 int64 uint8 uint16 uint32 uint64].each do |dtype|
      context "when array type is #{dtype}" do
        let(:x) { rng.bernoulli(shape: [10_000], p: 0.4, dtype: dtype) }

        it 'obtained randomized integer number from a binomial distribution', :aggregate_failures do
          expect(x.eq(1).count.fdiv(10_000)).to be_within(1e-2).of(0.4)
          expect(x.eq(0).count.fdiv(10_000)).to be_within(1e-2).of(0.6)
          expect(x.median).to eq(0)
        end
      end
    end
  end

  describe '#binomial' do
    %i[int8 int16 int32 int64 uint8 uint16 uint32 uint64].each do |dtype|
      context "when array type is #{dtype}" do
        let(:x) { rng.binomial(shape: [1000], n: 50, p: 0.4, dtype: dtype) }

        it 'obtained randomized integer number from a binomial distribution', :aggregate_failures do
          expect(x.median).to be_within(1e-2).of(20)
        end
      end
    end
  end

  describe '#negative_binomial' do
    %i[int8 int16 int32 int64 uint8 uint16 uint32 uint64].each do |dtype|
      context "when array type is #{dtype}" do
        let(:x) { rng.negative_binomial(shape: [1000], n: 14, p: 0.4, dtype: dtype) }

        it 'obtained randomized integer number from a negative binomial distribution', :aggregate_failures do
          expect(x.median).to be_within(1e-2).of(20)
        end
      end
    end
  end

  describe '#geometric' do
    %i[int8 int16 int32 int64 uint8 uint16 uint32 uint64].each do |dtype|
      context "when array type is #{dtype}" do
        let(:x) { rng.geometric(shape: [10_000], p: 0.4, dtype: dtype) }

        it 'obtained randomized integer number from a geometric distribution', :aggregate_failures do
          expect(x.eq(0).count.fdiv(10_000)).to be_within(1e-2).of(0.4)
        end
      end
    end
  end

  describe '#exponential' do
    context 'when array type is DFloat' do
      let(:x) { rng.exponential(shape: [500, 20], scale: 0.5) }

      it 'obtains random numbers form an exponential distribution', :aggregate_failures do
        expect(x).to be_a(Numo::DFloat)
        expect(x.mean).to be_within(1e-2).of(0.5)
        expect(x.var).to be_within(1e-2).of(0.25)
      end
    end

    context 'when array type is SFloat' do
      let(:x) { rng.exponential(shape: [500, 20], scale: 0.5, dtype: :float32) }

      it 'obtains random numbers form an exponential distribution', :aggregate_failures do
        expect(x).to be_a(Numo::SFloat)
        expect(x.mean).to be_within(1e-2).of(0.5)
        expect(x.var).to be_within(1e-2).of(0.25)
      end
    end
  end

  describe '#gamma' do
    context 'when array type is DFloat' do
      let(:x) { rng.gamma(shape: [500, 200], k: 0.5, scale: 2) }

      it 'obtains random numbers form a gamma distribution', :aggregate_failures do
        expect(x).to be_a(Numo::DFloat)
        expect(x.mean).to be_within(1e-2).of(1)
        expect(x.var).to be_within(1e-2).of(2)
      end
    end

    context 'when array type is SFloat' do
      let(:x) { rng.gamma(shape: [500, 200], k: 0.5, scale: 2, dtype: :float32) }

      it 'obtains random numbers form a gamma distribution', :aggregate_failures do
        expect(x).to be_a(Numo::SFloat)
        expect(x.mean).to be_within(1e-2).of(1)
        expect(x.var).to be_within(1e-2).of(2)
      end
    end
  end

  describe '#gumbel' do
    context 'when array type is DFloat' do
      let(:x) { rng.gumbel(shape: [500, 400]) }

      it 'obtains random numbers form the Gumbel distribution', :aggregate_failures do
        expect(x).to be_a(Numo::DFloat)
        expect(x.mean).to be_within(1e-2).of(0.57)
        expect(x.var).to be_within(2e-2).of((Math::PI**2).fdiv(6))
      end
    end

    context 'when array type is SFloat' do
      let(:x) { rng.gumbel(shape: [500, 400], dtype: :float32) }

      it 'obtains random numbers form the Gumbel distribution', :aggregate_failures do
        expect(x).to be_a(Numo::SFloat)
        expect(x.mean).to be_within(1e-2).of(0.57)
        expect(x.var).to be_within(2e-2).of((Math::PI**2).fdiv(6))
      end
    end
  end

  describe '#poisson' do
    %i[int8 int16 int32 int64 uint8 uint16 uint32 uint64].each do |dtype|
      context "when array type is #{dtype}" do
        let(:x) { rng.poisson(shape: [1000], mean: 4, dtype: dtype) }

        it 'obtained randomized integer number from the Poisson distribution', :aggregate_failures do
          expect(x.bincount.max_index).to eq(4)
        end
      end
    end
  end

  describe '#weibull' do
    context 'when array type is DFloat' do
      let(:x) { rng.weibull(shape: [500, 200], k: 5, scale: 2) }

      it 'obtains random numbers form the Weibull distribution', :aggregate_failures do
        expect(x).to be_a(Numo::DFloat)
        expect(x.mean).to be_within(1e-2).of(2 * Math.gamma(1.2))
        expect(x.var).to be_within(1e-2).of(4 * (Math.gamma(1.4) - Math.gamma(1.2)**2))
      end
    end

    context 'when array type is SFloat' do
      let(:x) { rng.weibull(shape: [500, 200], k: 5, scale: 2, dtype: :float32) }

      it 'obtains random numbers form the Weibull distribution', :aggregate_failures do
        expect(x).to be_a(Numo::SFloat)
        expect(x.mean).to be_within(1e-2).of(2 * Math.gamma(1.2))
        expect(x.var).to be_within(1e-2).of(4 * (Math.gamma(1.4) - Math.gamma(1.2)**2))
      end
    end
  end

  describe '#discrete' do
    let(:w) { Numo::DFloat[0.1, 0.6, 0.3] }

    %i[int8 int16 int32 int64 uint8 uint16 uint32 uint64].each do |dtype|
      context "when array type is #{dtype}" do
        let(:x) { rng.discrete(shape: [100, 100], weight: w, dtype: dtype) }

        it 'obtained randomized integer number from a discrete distribution', :aggregate_failures do
          expect(x.eq(0).count.fdiv(x.size)).to be_within(1e-2).of(w[0])
          expect(x.eq(1).count.fdiv(x.size)).to be_within(1e-2).of(w[1])
          expect(x.eq(2).count.fdiv(x.size)).to be_within(1e-2).of(w[2])
        end
      end
    end
  end

  describe '#uniform' do
    context 'when array type is DFloat' do
      let(:x) { rng.uniform(shape: [500, 600], low: 1, high: 4) }

      it 'obtains random numbers form a uniform distribution', :aggregate_failures do
        expect(x).to be_a(Numo::DFloat)
        expect(x.mean).to be_within(1e-2).of(2.5)
        expect(x.var).to be_within(1e-2).of(0.75)
      end
    end

    context 'when array type is SFloat' do
      let(:x) { rng.uniform(shape: [500, 600], low: 1, high: 4, dtype: :float32) }

      it 'obtains random numbers form a uniform distribution', :aggregate_failures do
        expect(x).to be_a(Numo::SFloat)
        expect(x.mean).to be_within(1e-2).of(2.5)
        expect(x.var).to be_within(1e-2).of(0.75)
      end
    end
  end

  describe '#cauchy' do
    let(:mad) { (x - x.median).abs.median }

    context 'when array type is DFloat' do
      let(:x) { rng.cauchy(shape: [500, 200]) }

      it 'obtains random numbers form a cauchy distribution', :aggregate_failures do
        expect(x).to be_a(Numo::DFloat)
        expect(x.median).to be_within(1e-2).of(0)
        expect(mad).to be_within(1e-2).of(1)
      end
    end

    context 'when array type is SFloat' do
      let(:x) { rng.cauchy(shape: [500, 200], dtype: :float32) }

      it 'obtains random numbers form a normal distribution', :aggregate_failures do
        expect(x).to be_a(Numo::SFloat)
        expect(x.median).to be_within(1e-2).of(0)
        expect(mad).to be_within(1e-2).of(1)
      end
    end

    context 'when loc and scale parameters are given' do
      let(:x) { rng.cauchy(shape: [500, 200], loc: 4, scale: 2) }

      it 'obtains random numbers form a normal distribution along with given parameters', :aggregate_failures do
        expect(x.median).to be_within(1e-2).of(4)
        expect(mad).to be_within(1e-2).of(2)
      end
    end
  end

  describe '#chisquare' do
    context 'when array type is DFloat' do
      let(:x) { rng.chisquare(shape: [500, 600], df: 2) }

      it 'obtains random numbers form a chi-squared distribution', :aggregate_failures do
        expect(x).to be_a(Numo::DFloat)
        expect(x.mean).to be_within(1e-2).of(2)
        expect(x.var).to be_within(1e-1).of(4)
      end
    end

    context 'when array type is SFloat' do
      let(:x) { rng.chisquare(shape: [500, 600], df: 2, dtype: :float32) }

      it 'obtains random numbers form a chi-squared distribution', :aggregate_failures do
        expect(x).to be_a(Numo::SFloat)
        expect(x.mean).to be_within(1e-2).of(2)
        expect(x.var).to be_within(1e-1).of(4)
      end
    end
  end

  describe '#f' do
    context 'when array type is DFloat' do
      let(:x) { rng.f(shape: [500, 600], dfnum: 5, dfden: 10) }

      it 'obtains random numbers form a F-distribution', :aggregate_failures do
        expect(x).to be_a(Numo::DFloat)
        expect(x.mean).to be_within(1e-2).of(1.25)
        expect(x.var).to be_within(1e-1).of(1.354)
      end
    end

    context 'when array type is SFloat' do
      let(:x) { rng.f(shape: [500, 600], dfnum: 5, dfden: 10, dtype: :float32) }

      it 'obtains random numbers form a F-distribution', :aggregate_failures do
        expect(x).to be_a(Numo::SFloat)
        expect(x.mean).to be_within(1e-2).of(1.25)
        expect(x.var).to be_within(1e-1).of(1.354)
      end
    end
  end

  describe '#normal' do
    context 'when array type is DFloat' do
      let(:x) { rng.normal(shape: [500, 200]) }

      it 'obtains random numbers form a normal distribution', :aggregate_failures do
        expect(x).to be_a(Numo::DFloat)
        expect(x.mean).to be_within(1e-2).of(0)
        expect(x.stddev).to be_within(1e-2).of(1)
      end
    end

    context 'when array type is SFloat' do
      let(:x) { rng.normal(shape: [500, 200], dtype: :float32) }

      it 'obtains random numbers form a normal distribution', :aggregate_failures do
        expect(x).to be_a(Numo::SFloat)
        expect(x.mean).to be_within(1e-2).of(0)
        expect(x.stddev).to be_within(1e-2).of(1)
      end
    end

    context 'when loc and scale parameters are given' do
      let(:x) { rng.normal(shape: [500, 200], loc: 10, scale: 2) }

      it 'obtains random numbers form a normal distribution along with given parameters', :aggregate_failures do
        expect(x.mean).to be_within(1e-2).of(10)
        expect(x.stddev).to be_within(1e-2).of(2)
      end
    end
  end

  describe '#lognormal' do
    context 'when array type is DFloat' do
      let(:x) { rng.lognormal(shape: [500, 600]) }

      it 'obtains random numbers form a lognormal distribution', :aggregate_failures do
        expect(x).to be_a(Numo::DFloat)
        expect(x.mean).to be_within(1e-2).of(Math.exp(0.5))
        expect(x.var).to be_within(1e-1).of(Math.exp(2) - Math.exp(1))
      end
    end

    context 'when array type is SFloat' do
      let(:x) { rng.lognormal(shape: [500, 600], dtype: :float32) }

      it 'obtains random numbers form a lognormal distribution', :aggregate_failures do
        expect(x).to be_a(Numo::SFloat)
        expect(x.mean).to be_within(1e-2).of(Math.exp(0.5))
        expect(x.var).to be_within(1e-1).of(Math.exp(2) - Math.exp(1))
      end
    end

    context 'when loc and scale parameters are given' do
      let(:x) { rng.lognormal(shape: [500, 800], mean: 0.5, sigma: 1) }

      it 'obtains random numbers form a lognormal distribution along with given parameters', :aggregate_failures do
        expect(x.mean).to be_within(1e-2).of(Math.exp(1))
        expect(x.var).to be_within(1e-1).of(Math.exp(3) - Math.exp(2))
      end
    end
  end

  describe '#standard_t' do
    context 'when array type is DFloat' do
      let(:x) { rng.standard_t(shape: [500, 600], df: 10) }

      it "obtains random numbers form a Student's t-distribution", :aggregate_failures do
        expect(x).to be_a(Numo::DFloat)
        expect(x.mean).to be_within(1e-2).of(0)
        expect(x.var).to be_within(1e-2).of(1.25)
      end
    end

    context 'when array type is SFloat' do
      let(:x) { rng.standard_t(shape: [500, 600], df: 10, dtype: :float32) }

      it "obtains random numbers form a Student's t-distribution", :aggregate_failures do
        expect(x).to be_a(Numo::SFloat)
        expect(x.mean).to be_within(1e-2).of(0)
        expect(x.var).to be_within(1e-2).of(1.25)
      end
    end
  end
end
