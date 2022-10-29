# frozen_string_literal: true

RSpec.describe Numo::Random::Generator do
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

    %i[float32 float64 sfloat dfloat].each do |dtype|
      context "when array type is #{dtype}" do
        it 'raises TypeError' do
          expect do
            rng.discrete(shape: [2, 2], weight: w, dtype: dtype)
          end.to raise_error(TypeError, 'invalid NArray class, it must be integer typed array')
        end
      end
    end

    context 'when given integer typed array to weight' do
      let(:w) { Numo::Int32[1, 6, 3] }

      it 'raises TypeError' do
        expect do
          rng.discrete(shape: 2, weight: w)
        end.to raise_error(TypeError, 'weight must be Numo::DFloat or Numo::SFloat')
      end
    end

    context 'when given multi-dimensional array to weight' do
      let(:w) { Numo::DFloat[[0.1, 0.6, 0.3], [0.1, 0.1, 0.8]] }

      it 'raises ArgumentError' do
        expect { rng.discrete(shape: 2, weight: w) }.to raise_error(ArgumentError, 'weight must be 1-dimensional array')
      end
    end

    context 'when given empty array to weight' do
      let(:w) { Numo::DFloat[] }

      it 'raises ArgumentError' do
        expect { rng.discrete(shape: 2, weight: w) }.to raise_error(ArgumentError, 'length of weight must be > 0')
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

    context 'when high - low is negative value' do
      it 'raises ArgumentError' do
        expect { rng.uniform(shape: 5, low: 10, high: 5) }.to raise_error(ArgumentError, 'high - low must be > 0')
      end
    end

    context 'when array type is Int32' do
      it 'raises TypeError' do
        expect do
          rng.uniform(shape: 5, dtype: :int32)
        end.to raise_error(TypeError, 'invalid NArray class, it must be DFloat or SFloat')
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

    context 'when negative value is given to scale' do
      it 'raises ArgumentError' do
        expect { rng.cauchy(shape: 5, scale: -100) }.to raise_error(ArgumentError, 'scale must be a non-negative value')
      end
    end

    context 'when array type is Int32' do
      it 'raises TypeError' do
        expect do
          rng.cauchy(shape: 5, dtype: :int32)
        end.to raise_error(TypeError, 'invalid NArray class, it must be DFloat or SFloat')
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

    context 'when negative value is given to df' do
      it 'raises ArgumentError' do
        expect { rng.chisquare(shape: 5, df: -1) }.to raise_error(ArgumentError, 'df must be > 0')
      end
    end

    context 'when zero is given to df' do
      it 'raises ArgumentError' do
        expect { rng.chisquare(shape: 5, df: 0) }.to raise_error(ArgumentError, 'df must be > 0')
      end
    end

    context 'when array type is Int32' do
      it 'raises TypeError' do
        expect do
          rng.chisquare(shape: 5, df: 1, dtype: :int32)
        end.to raise_error(TypeError, 'invalid NArray class, it must be DFloat or SFloat')
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

    context 'when negative value is given to dfnum' do
      it 'raises ArgumentError' do
        expect { rng.f(shape: 5, dfnum: -5, dfden: 10) }.to raise_error(ArgumentError, 'dfnum must be > 0')
      end
    end

    context 'when negative value is given to dfden' do
      it 'raises ArgumentError' do
        expect { rng.f(shape: 5, dfnum: 5, dfden: -10) }.to raise_error(ArgumentError, 'dfden must be > 0')
      end
    end

    context 'when zero is given to dfnum' do
      it 'raises ArgumentError' do
        expect { rng.f(shape: 5, dfnum: 0, dfden: 10) }.to raise_error(ArgumentError, 'dfnum must be > 0')
      end
    end

    context 'when zero is given to dfden' do
      it 'raises ArgumentError' do
        expect { rng.f(shape: 5, dfnum: 5, dfden: 0) }.to raise_error(ArgumentError, 'dfden must be > 0')
      end
    end

    context 'when array type is Int32' do
      it 'raises TypeError' do
        expect do
          rng.f(shape: 5, dfnum: 5, dfden: 10, dtype: :int32)
        end.to raise_error(TypeError, 'invalid NArray class, it must be DFloat or SFloat')
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

    context 'when negative value is given to scale' do
      it 'raises ArgumentError' do
        expect { rng.normal(shape: 5, scale: -100) }.to raise_error(ArgumentError, 'scale must be a non-negative value')
      end
    end

    context 'when array type is Int32' do
      it 'raises TypeError' do
        expect do
          rng.normal(shape: 5, dtype: :int32)
        end.to raise_error(TypeError, 'invalid NArray class, it must be DFloat or SFloat')
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

    context 'when negative value is given to sigma' do
      it 'raises ArgumentError' do
        expect do
          rng.lognormal(shape: 5, sigma: -100)
        end.to raise_error(ArgumentError, 'sigma must be a non-negative value')
      end
    end

    context 'when array type is Int32' do
      it 'raises TypeError' do
        expect do
          rng.lognormal(shape: 5, dtype: :int32)
        end.to raise_error(TypeError, 'invalid NArray class, it must be DFloat or SFloat')
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

    context 'when negative value is given to df' do
      it 'raises ArgumentError' do
        expect { rng.standard_t(shape: 5, df: -1) }.to raise_error(ArgumentError, 'df must be > 0')
      end
    end

    context 'when zero is given to df' do
      it 'raises ArgumentError' do
        expect { rng.standard_t(shape: 5, df: 0) }.to raise_error(ArgumentError, 'df must be > 0')
      end
    end

    context 'when array type is Int32' do
      it 'raises TypeError' do
        expect do
          rng.standard_t(shape: 5, df: 1, dtype: :int32)
        end.to raise_error(TypeError, 'invalid NArray class, it must be DFloat or SFloat')
      end
    end
  end
end
