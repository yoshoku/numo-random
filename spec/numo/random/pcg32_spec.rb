# frozen_string_literal: true

RSpec.describe Numo::Random::PCG32 do
  subject(:rng) { described_class.new(seed: 42) }

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

  describe '#binomial' do
    [Numo::Int8, Numo::Int16, Numo::Int32, Numo::Int64,
     Numo::UInt8, Numo::UInt16, Numo::UInt32, Numo::UInt64].each do |klass|
      context "when array type is #{klass}" do
        let(:x) { klass.new(1000).tap { |x| rng.binomial(x, n: 50, p: 0.4) } }

        it 'obtained randomized integer number from a binomial distribution', :aggregate_failures do
          expect(x).to be_a(klass)
          expect(x.median).to be_within(1e-2).of(20)
        end
      end
    end

    [Numo::SFloat, Numo::DFloat].each do |klass|
      context "when array type is #{klass}" do
        let(:x) { klass.new(5) }

        it 'raises TypeError' do
          expect do
            rng.binomial(x, n: 5, p: 0.5)
          end.to raise_error(TypeError, 'invalid NArray class, it must be integer typed array')
        end
      end
    end

    context 'when negative value is given to n' do
      let(:x) { Numo::Int32.new(5) }

      it 'raises ArgumentError' do
        expect { rng.binomial(x, n: -1, p: 0.5) }.to raise_error(ArgumentError, 'n must be a non-negative value')
      end
    end

    context 'when negative value is given to p' do
      let(:x) { Numo::Int32.new(5) }

      it 'raises ArgumentError' do
        expect { rng.binomial(x, n: 5, p: -0.1) }.to raise_error(ArgumentError, 'p must be >= 0 and <= 1')
      end
    end

    context 'when a value greater then 1 is given to p' do
      let(:x) { Numo::Int32.new(5) }

      it 'raises ArgumentError' do
        expect { rng.binomial(x, n: 5, p: 1.1) }.to raise_error(ArgumentError, 'p must be >= 0 and <= 1')
      end
    end
  end

  describe '#negative_binomial' do
    [Numo::Int8, Numo::Int16, Numo::Int32, Numo::Int64,
     Numo::UInt8, Numo::UInt16, Numo::UInt32, Numo::UInt64].each do |klass|
      context "when array type is #{klass}" do
        let(:x) { klass.new(10_000).tap { |x| rng.negative_binomial(x, n: 14, p: 0.4) } }

        it 'obtained randomized integer number from a negative binomial distribution', :aggregate_failures do
          expect(x).to be_a(klass)
          expect(x.median).to be_within(1e-2).of(20)
        end
      end
    end

    [Numo::SFloat, Numo::DFloat].each do |klass|
      context "when array type is #{klass}" do
        let(:x) { klass.new(5) }

        it 'raises TypeError' do
          expect do
            rng.negative_binomial(x, n: 5, p: 0.5)
          end.to raise_error(TypeError, 'invalid NArray class, it must be integer typed array')
        end
      end
    end

    context 'when negative value is given to n' do
      let(:x) { Numo::Int32.new(5) }

      it 'raises ArgumentError' do
        expect do
          rng.negative_binomial(x, n: -1, p: 0.5)
        end.to raise_error(ArgumentError, 'n must be a non-negative value')
      end
    end

    context 'when negative value is given to p' do
      let(:x) { Numo::Int32.new(5) }

      it 'raises ArgumentError' do
        expect { rng.negative_binomial(x, n: 5, p: -0.1) }.to raise_error(ArgumentError, 'p must be > 0 and <= 1')
      end
    end

    context 'when zero is given to p' do
      let(:x) { Numo::Int32.new(5) }

      it 'raises ArgumentError' do
        expect { rng.negative_binomial(x, n: 5, p: 0) }.to raise_error(ArgumentError, 'p must be > 0 and <= 1')
      end
    end

    context 'when a value greater then 1 is given to p' do
      let(:x) { Numo::Int32.new(5) }

      it 'raises ArgumentError' do
        expect { rng.negative_binomial(x, n: 5, p: 1.1) }.to raise_error(ArgumentError, 'p must be > 0 and <= 1')
      end
    end
  end

  describe '#geometric' do
    [Numo::Int8, Numo::Int16, Numo::Int32, Numo::Int64,
     Numo::UInt8, Numo::UInt16, Numo::UInt32, Numo::UInt64].each do |klass|
      context "when array type is #{klass}" do
        let(:x) { klass.new(10_000).tap { |x| rng.geometric(x, p: 0.4) } }

        it 'obtained randomized integer number from a geometric distribution', :aggregate_failures do
          expect(x).to be_a(klass)
          expect(x.eq(0).count.fdiv(10_000)).to be_within(1e-2).of(0.4)
        end
      end
    end

    [Numo::SFloat, Numo::DFloat].each do |klass|
      context "when array type is #{klass}" do
        let(:x) { klass.new(5) }

        it 'raises TypeError' do
          expect do
            rng.geometric(x, p: 0.5)
          end.to raise_error(TypeError, 'invalid NArray class, it must be integer typed array')
        end
      end
    end

    context 'when negative value is given to p' do
      let(:x) { Numo::Int32.new(5) }

      it 'raises ArgumentError' do
        expect { rng.geometric(x, p: -0.1) }.to raise_error(ArgumentError, 'p must be > 0 and < 1')
      end
    end

    context 'when zero is given to p' do
      let(:x) { Numo::Int32.new(5) }

      it 'raises ArgumentError' do
        expect { rng.geometric(x, p: 0) }.to raise_error(ArgumentError, 'p must be > 0 and < 1')
      end
    end

    context 'when a value greater then 1 is given to p' do
      let(:x) { Numo::Int32.new(5) }

      it 'raises ArgumentError' do
        expect { rng.geometric(x, p: 1.1) }.to raise_error(ArgumentError, 'p must be > 0 and < 1')
      end
    end

    context 'when one is given to p' do
      let(:x) { Numo::Int32.new(5) }

      it 'raises ArgumentError' do
        expect { rng.geometric(x, p: 1) }.to raise_error(ArgumentError, 'p must be > 0 and < 1')
      end
    end
  end

  describe '#exponential' do
    [Numo::SFloat, Numo::DFloat].each do |klass|
      context "when array type is #{klass}" do
        let(:x) { klass.new(5000).tap { |x| rng.exponential(x, scale: 0.5) } }

        it 'obtains random numbers from an exponential distribution', :aggregate_failures do
          expect(x).to be_a(klass)
          expect(x.mean).to be_within(1e-2).of(0.5)
          expect(x.var).to be_within(1e-2).of(0.25)
        end
      end
    end

    context 'when scale is negative value' do
      let(:x) { Numo::DFloat.new(5) }

      it 'raises ArgumentError' do
        expect { rng.exponential(x, scale: -1) }.to raise_error(ArgumentError, 'scale must be > 0')
      end
    end

    context 'when scale is given to mean' do
      let(:x) { Numo::DFloat.new(5) }

      it 'raises ArgumentError' do
        expect { rng.exponential(x, scale: 0) }.to raise_error(ArgumentError, 'scale must be > 0')
      end
    end

    context 'when array type is Int32' do
      let(:x) { Numo::Int32.new(5) }

      it 'raises TypeError' do
        expect { rng.exponential(x) }.to raise_error(TypeError, 'invalid NArray class, it must be DFloat or SFloat')
      end
    end
  end

  describe '#gamma' do
    [Numo::SFloat, Numo::DFloat].each do |klass|
      context "when array type is #{klass}" do
        let(:x) { klass.new(500, 100).tap { |x| rng.gamma(x, k: 9, scale: 0.5) } }

        it 'obtains random numbers form a gamma distribution', :aggregate_failures do
          expect(x).to be_a(klass)
          expect(x.mean).to be_within(1e-2).of(4.5)
          expect(x.var).to be_within(1e-1).of(2.25)
        end
      end
    end

    context 'when negative value is given to k' do
      let(:x) { Numo::DFloat.new(5) }

      it 'raises ArgumentError' do
        expect { rng.gamma(x, k: -5) }.to raise_error(ArgumentError, 'k must be > 0')
      end
    end

    context 'when negative value is given to scale' do
      let(:x) { Numo::DFloat.new(5) }

      it 'raises ArgumentError' do
        expect { rng.gamma(x, k: 1, scale: -10) }.to raise_error(ArgumentError, 'scale must be > 0')
      end
    end

    context 'when zero is given to k' do
      let(:x) { Numo::DFloat.new(5) }

      it 'raises ArgumentError' do
        expect { rng.gamma(x, k: 0) }.to raise_error(ArgumentError, 'k must be > 0')
      end
    end

    context 'when zero is given to scale' do
      let(:x) { Numo::DFloat.new(5) }

      it 'raises ArgumentError' do
        expect { rng.gamma(x, k: 1, scale: 0) }.to raise_error(ArgumentError, 'scale must be > 0')
      end
    end

    context 'when array type is Int32' do
      let(:x) { Numo::Int32.new(5) }

      it 'raises TypeError' do
        expect { rng.gamma(x, k: 1) }.to raise_error(TypeError, 'invalid NArray class, it must be DFloat or SFloat')
      end
    end
  end

  describe '#gumbel' do
    [Numo::SFloat, Numo::DFloat].each do |klass|
      context 'when array type is DFloat' do
        let(:x) { klass.new(500, 600).tap { |x| rng.gumbel(x) } }

        it 'obtains random numbers form the Gumbel distribution', :aggregate_failures do
          expect(x).to be_a(klass)
          expect(x.mean).to be_within(1e-2).of(0.57)
          expect(x.var).to be_within(2e-2).of((Math::PI**2).fdiv(6))
        end
      end
    end

    context 'when loc and scale parameters are given' do
      let(:x) { Numo::DFloat.new(500, 600).tap { |x| rng.gumbel(x, loc: 4, scale: 3) } }

      it 'obtains random numbers form a normal distribution along with given parameters', :aggregate_failures do
        expect(x.mean).to be_within(1e-2).of(4 + 3 * 0.577)
        expect(x.var).to be_within(1e-1).of((Math::PI**2).fdiv(6) * 9)
      end
    end

    context 'when negative value is given to scale' do
      let(:x) { Numo::DFloat.new(5) }

      it 'raises ArgumentError' do
        expect { rng.gumbel(x, scale: -100) }.to raise_error(ArgumentError, 'scale must be > 0')
      end
    end

    context 'when zero is given to scale' do
      let(:x) { Numo::DFloat.new(5) }

      it 'raises ArgumentError' do
        expect { rng.gumbel(x, scale: 0) }.to raise_error(ArgumentError, 'scale must be > 0')
      end
    end

    context 'when array type is Int32' do
      let(:x) { Numo::Int32.new(5) }

      it 'raises TypeError' do
        expect { rng.gumbel(x) }.to raise_error(TypeError, 'invalid NArray class, it must be DFloat or SFloat')
      end
    end
  end

  describe '#poisson' do
    [Numo::Int8, Numo::Int16, Numo::Int32, Numo::Int64,
     Numo::UInt8, Numo::UInt16, Numo::UInt32, Numo::UInt64].each do |klass|
      context "when array type is #{klass}" do
        let(:x) { klass.new(100_000).tap { |x| rng.poisson(x, mean: 3) } }

        it 'obtained randomized integer number from the Poisson distribution', :aggregate_failures do
          expect(x).to be_a(klass)
          expect(x.bincount.max_index).to eq(3)
        end
      end
    end

    [Numo::SFloat, Numo::DFloat].each do |klass|
      context "when array type is #{klass}" do
        let(:x) { klass.new(5) }

        it 'raises TypeError' do
          expect { rng.poisson(x) }.to raise_error(TypeError, 'invalid NArray class, it must be integer typed array')
        end
      end
    end

    context 'when negative value is given to mean' do
      let(:x) { Numo::Int32.new(5) }

      it 'raises ArgumentError' do
        expect { rng.poisson(x, mean: -1) }.to raise_error(ArgumentError, 'mean must be > 0')
      end
    end

    context 'when zero is given to mean' do
      let(:x) { Numo::Int32.new(5) }

      it 'raises ArgumentError' do
        expect { rng.poisson(x, mean: 0) }.to raise_error(ArgumentError, 'mean must be > 0')
      end
    end
  end

  describe '#weibull' do
    [Numo::SFloat, Numo::DFloat].each do |klass|
      context "when array type is #{klass}" do
        let(:x) { klass.new(500, 200).tap { |x| rng.weibull(x, k: 5) } }

        it 'obtains random numbers form the Weibull distribution', :aggregate_failures do
          expect(x.mean).to be_within(1e-2).of(Math.gamma(1.2))
          expect(x.var).to be_within(1e-2).of(Math.gamma(1.4) - Math.gamma(1.2)**2)
        end
      end
    end

    context 'when negative value is given to k' do
      let(:x) { Numo::DFloat.new(5) }

      it 'raises ArgumentError' do
        expect { rng.weibull(x, k: -5) }.to raise_error(ArgumentError, 'k must be > 0')
      end
    end

    context 'when negative value is given to scale' do
      let(:x) { Numo::DFloat.new(5) }

      it 'raises ArgumentError' do
        expect { rng.weibull(x, k: 1, scale: -10) }.to raise_error(ArgumentError, 'scale must be > 0')
      end
    end

    context 'when zero is given to k' do
      let(:x) { Numo::DFloat.new(5) }

      it 'raises ArgumentError' do
        expect { rng.weibull(x, k: 0) }.to raise_error(ArgumentError, 'k must be > 0')
      end
    end

    context 'when zero is given to scale' do
      let(:x) { Numo::DFloat.new(5) }

      it 'raises ArgumentError' do
        expect { rng.weibull(x, k: 1, scale: 0) }.to raise_error(ArgumentError, 'scale must be > 0')
      end
    end

    context 'when array type is Int32' do
      let(:x) { Numo::Int32.new(5) }

      it 'raises TypeError' do
        expect { rng.weibull(x, k: 1) }.to raise_error(TypeError, 'invalid NArray class, it must be DFloat or SFloat')
      end
    end
  end

  describe '#discrete' do
    let(:w) { Numo::DFloat[0.1, 0.6, 0.3] }

    [Numo::Int8, Numo::Int16, Numo::Int32, Numo::Int64,
     Numo::UInt8, Numo::UInt16, Numo::UInt32, Numo::UInt64].each do |klass|
      context "when array type is #{klass}" do
        let(:x) { klass.new(100, 100).tap { |x| rng.discrete(x, weight: w) } }

        it 'obtained randomized integer number from a discrete distribution', :aggregate_failures do
          expect(x).to be_a(klass)
          expect(x.eq(0).count.fdiv(x.size)).to be_within(1e-2).of(w[0])
          expect(x.eq(1).count.fdiv(x.size)).to be_within(1e-2).of(w[1])
          expect(x.eq(2).count.fdiv(x.size)).to be_within(1e-2).of(w[2])
        end
      end
    end

    [Numo::SFloat, Numo::DFloat].each do |klass|
      context "when array type is #{klass}" do
        let(:x) { klass.new(2, 2) }

        it 'raises TypeError' do
          expect do
            rng.discrete(x, weight: w)
          end.to raise_error(TypeError, 'invalid NArray class, it must be integer typed array')
        end
      end
    end

    context 'when given integer typed array to weight' do
      let(:x) { Numo::Int32.new(2, 2) }
      let(:w) { Numo::Int32[1, 6, 3] }

      it 'raises TypeError' do
        expect { rng.discrete(x, weight: w) }.to raise_error(TypeError, 'weight must be Numo::DFloat or Numo::SFloat')
      end
    end

    context 'when given multi-dimensional array to weight' do
      let(:x) { Numo::Int32.new(2, 2) }
      let(:w) { Numo::DFloat[[0.1, 0.6, 0.3], [0.1, 0.1, 0.8]] }

      it 'raises ArgumentError' do
        expect { rng.discrete(x, weight: w) }.to raise_error(ArgumentError, 'weight must be 1-dimensional array')
      end
    end

    context 'when given empty array to weight' do
      let(:x) { Numo::Int32.new(2, 2) }
      let(:w) { Numo::DFloat[] }

      it 'raises ArgumentError' do
        expect { rng.discrete(x, weight: w) }.to raise_error(ArgumentError, 'length of weight must be > 0')
      end
    end
  end

  describe '#uniform' do
    context 'when array type is DFloat' do
      let(:x) { Numo::DFloat.new(500, 600).tap { |x| rng.uniform(x, low: 1, high: 4) } }

      it 'obtains random numbers form a uniform distribution', :aggregate_failures do
        expect(x).to be_a(Numo::DFloat)
        expect(x.mean).to be_within(1e-2).of(2.5)
        expect(x.var).to be_within(1e-2).of(0.75)
      end
    end

    context 'when array type is SFloat' do
      let(:x) { Numo::SFloat.new(500, 600).tap { |x| rng.uniform(x, low: 1, high: 4) } }

      it 'obtains random numbers form a uniform distribution', :aggregate_failures do
        expect(x).to be_a(Numo::SFloat)
        expect(x.mean).to be_within(1e-2).of(2.5)
        expect(x.var).to be_within(1e-2).of(0.75)
      end
    end

    context 'when high - low is negative value' do
      let(:x) { Numo::DFloat.new(5, 2) }

      it 'raises ArgumentError' do
        expect { rng.uniform(x, low: 10, high: 5) }.to raise_error(ArgumentError, 'high - low must be > 0')
      end
    end

    context 'when array type is Int32' do
      let(:x) { Numo::Int32.new(5, 2) }

      it 'raises TypeError' do
        expect { rng.uniform(x) }.to raise_error(TypeError, 'invalid NArray class, it must be DFloat or SFloat')
      end
    end
  end

  describe '#cauchy' do
    let(:mad) { (x - x.median).abs.median }

    context 'when array type is DFloat' do
      let(:x) { Numo::DFloat.new(500, 200).tap { |x| rng.cauchy(x) } }

      it 'obtains random numbers form a cauchy distribution', :aggregate_failures do
        expect(x).to be_a(Numo::DFloat)
        expect(x.median).to be_within(1e-2).of(0)
        expect(mad).to be_within(1e-2).of(1)
      end
    end

    context 'when array type is SFloat' do
      let(:x) { Numo::SFloat.new(500, 200).tap { |x| rng.cauchy(x) } }

      it 'obtains random numbers form a normal distribution', :aggregate_failures do
        expect(x).to be_a(Numo::SFloat)
        expect(x.median).to be_within(1e-2).of(0)
        expect(mad).to be_within(1e-2).of(1)
      end
    end

    context 'when loc and scale parameters are given' do
      let(:x) { Numo::DFloat.new(500, 200).tap { |x| rng.cauchy(x, loc: 4, scale: 2) } }

      it 'obtains random numbers form a normal distribution along with given parameters', :aggregate_failures do
        expect(x.median).to be_within(1e-2).of(4)
        expect(mad).to be_within(1e-2).of(2)
      end
    end

    context 'when negative value is given to scale' do
      let(:x) { Numo::DFloat.new(5, 2) }

      it 'raises ArgumentError' do
        expect { rng.cauchy(x, scale: -100) }.to raise_error(ArgumentError, 'scale must be a non-negative value')
      end
    end

    context 'when array type is Int32' do
      let(:x) { Numo::Int32.new(5, 2) }

      it 'raises TypeError' do
        expect { rng.cauchy(x) }.to raise_error(TypeError, 'invalid NArray class, it must be DFloat or SFloat')
      end
    end
  end

  describe '#chisquare' do
    context 'when array type is DFloat' do
      let(:x) { Numo::DFloat.new(500, 600).tap { |x| rng.chisquare(x, df: 2) } }

      it 'obtains random numbers form a chi-squared distribution', :aggregate_failures do
        expect(x).to be_a(Numo::DFloat)
        expect(x.mean).to be_within(1e-2).of(2)
        expect(x.var).to be_within(1e-1).of(4)
      end
    end

    context 'when array type is SFloat' do
      let(:x) { Numo::SFloat.new(500, 600).tap { |x| rng.chisquare(x, df: 2) } }

      it 'obtains random numbers form a chi-squared distribution', :aggregate_failures do
        expect(x).to be_a(Numo::SFloat)
        expect(x.mean).to be_within(1e-2).of(2)
        expect(x.var).to be_within(1e-1).of(4)
      end
    end

    context 'when negative value is given to df' do
      let(:x) { Numo::DFloat.new(5, 2) }

      it 'raises ArgumentError' do
        expect { rng.chisquare(x, df: -1) }.to raise_error(ArgumentError, 'df must be > 0')
      end
    end

    context 'when zero is given to df' do
      let(:x) { Numo::DFloat.new(5, 2) }

      it 'raises ArgumentError' do
        expect { rng.chisquare(x, df: 0) }.to raise_error(ArgumentError, 'df must be > 0')
      end
    end

    context 'when array type is Int32' do
      let(:x) { Numo::Int32.new(5, 2) }

      it 'raises TypeError' do
        expect do
          rng.chisquare(x, df: 1)
        end.to raise_error(TypeError, 'invalid NArray class, it must be DFloat or SFloat')
      end
    end
  end

  describe '#f' do
    context 'when array type is DFloat' do
      let(:x) { Numo::DFloat.new(500, 600).tap { |x| rng.f(x, dfnum: 5, dfden: 10) } }

      it 'obtains random numbers form a F-distribution', :aggregate_failures do
        expect(x).to be_a(Numo::DFloat)
        expect(x.mean).to be_within(1e-2).of(1.25)
        expect(x.var).to be_within(1e-1).of(1.354)
      end
    end

    context 'when array type is SFloat' do
      let(:x) { Numo::SFloat.new(500, 600).tap { |x| rng.f(x, dfnum: 5, dfden: 10) } }

      it 'obtains random numbers form a F-distribution', :aggregate_failures do
        expect(x).to be_a(Numo::SFloat)
        expect(x.mean).to be_within(1e-2).of(1.25)
        expect(x.var).to be_within(1e-1).of(1.354)
      end
    end

    context 'when negative value is given to dfnum' do
      let(:x) { Numo::DFloat.new(5, 2) }

      it 'raises ArgumentError' do
        expect { rng.f(x, dfnum: -5, dfden: 10) }.to raise_error(ArgumentError, 'dfnum must be > 0')
      end
    end

    context 'when negative value is given to dfden' do
      let(:x) { Numo::DFloat.new(5, 2) }

      it 'raises ArgumentError' do
        expect { rng.f(x, dfnum: 5, dfden: -10) }.to raise_error(ArgumentError, 'dfden must be > 0')
      end
    end

    context 'when zero is given to dfnum' do
      let(:x) { Numo::DFloat.new(5, 2) }

      it 'raises ArgumentError' do
        expect { rng.f(x, dfnum: 0, dfden: 10) }.to raise_error(ArgumentError, 'dfnum must be > 0')
      end
    end

    context 'when zero is given to dfden' do
      let(:x) { Numo::DFloat.new(5, 2) }

      it 'raises ArgumentError' do
        expect { rng.f(x, dfnum: 5, dfden: 0) }.to raise_error(ArgumentError, 'dfden must be > 0')
      end
    end

    context 'when array type is Int32' do
      let(:x) { Numo::Int32.new(5, 2) }

      it 'raises TypeError' do
        expect do
          rng.f(x, dfnum: 5, dfden: 10)
        end.to raise_error(TypeError, 'invalid NArray class, it must be DFloat or SFloat')
      end
    end
  end

  describe '#normal' do
    context 'when array type is DFloat' do
      let(:x) { Numo::DFloat.new(500, 200).tap { |x| rng.normal(x) } }

      it 'obtains random numbers form a normal distribution', :aggregate_failures do
        expect(x).to be_a(Numo::DFloat)
        expect(x.mean).to be_within(1e-2).of(0)
        expect(x.stddev).to be_within(1e-2).of(1)
      end
    end

    context 'when array type is SFloat' do
      let(:x) { Numo::SFloat.new(500, 200).tap { |x| rng.normal(x) } }

      it 'obtains random numbers form a normal distribution', :aggregate_failures do
        expect(x).to be_a(Numo::SFloat)
        expect(x.mean).to be_within(1e-2).of(0)
        expect(x.stddev).to be_within(1e-2).of(1)
      end
    end

    context 'when loc and scale parameters are given' do
      let(:x) { Numo::DFloat.new(500, 200).tap { |x| rng.normal(x, loc: 10, scale: 2) } }

      it 'obtains random numbers form a normal distribution along with given parameters', :aggregate_failures do
        expect(x.mean).to be_within(1e-2).of(10)
        expect(x.stddev).to be_within(1e-2).of(2)
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

  describe '#lognormal' do
    context 'when array type is DFloat' do
      let(:x) { Numo::DFloat.new(500, 1000).tap { |x| rng.lognormal(x) } }

      it 'obtains random numbers form a lognormal distribution', :aggregate_failures do
        expect(x).to be_a(Numo::DFloat)
        expect(x.mean).to be_within(1e-2).of(Math.exp(0.5))
        expect(x.var).to be_within(1e-1).of(Math.exp(2) - Math.exp(1))
      end
    end

    context 'when array type is SFloat' do
      let(:x) { Numo::SFloat.new(500, 600).tap { |x| rng.lognormal(x) } }

      it 'obtains random numbers form a lognormal distribution', :aggregate_failures do
        expect(x).to be_a(Numo::SFloat)
        expect(x.mean).to be_within(1e-2).of(Math.exp(0.5))
        expect(x.var).to be_within(1e-1).of(Math.exp(2) - Math.exp(1))
      end
    end

    context 'when loc and scale parameters are given' do
      let(:x) { Numo::DFloat.new(500, 1000).tap { |x| rng.lognormal(x, mean: 0.5, sigma: 1) } }

      it 'obtains random numbers form a lognormal distribution along with given parameters', :aggregate_failures do
        expect(x.mean).to be_within(1e-1).of(Math.exp(1))
        expect(x.var).to be_within(3e-1).of(Math.exp(3) - Math.exp(2))
      end
    end

    context 'when negative value is given to sigma' do
      let(:x) { Numo::DFloat.new(5, 2) }

      it 'raises ArgumentError' do
        expect { rng.lognormal(x, sigma: -100) }.to raise_error(ArgumentError, 'sigma must be a non-negative value')
      end
    end

    context 'when array type is Int32' do
      let(:x) { Numo::Int32.new(5, 2) }

      it 'raises TypeError' do
        expect { rng.lognormal(x) }.to raise_error(TypeError, 'invalid NArray class, it must be DFloat or SFloat')
      end
    end
  end

  describe '#standard_t' do
    context 'when array type is DFloat' do
      let(:x) { Numo::DFloat.new(500, 600).tap { |x| rng.standard_t(x, df: 10) } }

      it "obtains random numbers form a Student's t-distribution", :aggregate_failures do
        expect(x).to be_a(Numo::DFloat)
        expect(x.mean).to be_within(1e-2).of(0)
        expect(x.var).to be_within(1e-2).of(1.25)
      end
    end

    context 'when array type is SFloat' do
      let(:x) { Numo::SFloat.new(500, 600).tap { |x| rng.standard_t(x, df: 10) } }

      it "obtains random numbers form a Student's t-distribution", :aggregate_failures do
        expect(x).to be_a(Numo::SFloat)
        expect(x.mean).to be_within(1e-2).of(0)
        expect(x.var).to be_within(1e-2).of(1.25)
      end
    end

    context 'when negative value is given to df' do
      let(:x) { Numo::DFloat.new(5, 2) }

      it 'raises ArgumentError' do
        expect { rng.standard_t(x, df: -1) }.to raise_error(ArgumentError, 'df must be > 0')
      end
    end

    context 'when zero is given to df' do
      let(:x) { Numo::DFloat.new(5, 2) }

      it 'raises ArgumentError' do
        expect { rng.standard_t(x, df: 0) }.to raise_error(ArgumentError, 'df must be > 0')
      end
    end

    context 'when array type is Int32' do
      let(:x) { Numo::Int32.new(5, 2) }

      it 'raises TypeError' do
        expect do
          rng.standard_t(x, df: 1)
        end.to raise_error(TypeError, 'invalid NArray class, it must be DFloat or SFloat')
      end
    end
  end
end
