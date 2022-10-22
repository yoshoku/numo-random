# frozen_string_literal: true

RSpec.describe Numo::Random do
  subject(:rng) { Numo::Random::PCG64.new(seed: 42) }

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

  describe '#uniform' do
    context 'when array type is DFloat' do
      let(:x) { Numo::DFloat.new(500, 600) }
      let(:y) { rng.uniform(x, low: 1, high: 4) }

      it 'obtains random numbers form a uniform distribution', :aggregate_failures do
        expect(y).to be_a(Numo::DFloat)
        expect(y.shape).to match(x.shape)
        expect(y.mean).to be_within(1e-2).of(2.5)
        expect(y.var).to be_within(1e-2).of(0.75)
      end
    end

    context 'when array type is SFloat' do
      let(:x) { Numo::SFloat.new(500, 600) }
      let(:y) { rng.uniform(x, low: 1, high: 4) }

      it 'obtains random numbers form a uniform distribution', :aggregate_failures do
        expect(y).to be_a(Numo::SFloat)
        expect(y.shape).to match(x.shape)
        expect(y.mean).to be_within(1e-2).of(2.5)
        expect(y.var).to be_within(1e-2).of(0.75)
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
    let(:mad) { (y - y.median).abs.median }

    context 'when array type is DFloat' do
      let(:x) { Numo::DFloat.new(500, 200) }
      let(:y) { rng.cauchy(x) }

      it 'obtains random numbers form a cauchy distribution', :aggregate_failures do
        expect(y).to be_a(Numo::DFloat)
        expect(y.shape).to match(x.shape)
        expect(y.median).to be_within(1e-2).of(0)
        expect(mad).to be_within(1e-2).of(1)
      end
    end

    context 'when array type is SFloat' do
      let(:x) { Numo::SFloat.new(500, 200) }
      let(:y) { rng.cauchy(x) }

      it 'obtains random numbers form a normal distribution', :aggregate_failures do
        expect(y).to be_a(Numo::SFloat)
        expect(y.shape).to match(x.shape)
        expect(y.median).to be_within(1e-2).of(0)
        expect(mad).to be_within(1e-2).of(1)
      end
    end

    context 'when loc and scale parameters are given' do
      let(:x) { Numo::DFloat.new(500, 200) }
      let(:y) { rng.cauchy(x, loc: 4, scale: 2) }

      it 'obtains random numbers form a normal distribution along with given parameters', :aggregate_failures do
        expect(y.median).to be_within(1e-2).of(4)
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
      let(:x) { Numo::DFloat.new(500, 600) }
      let(:y) { rng.chisquare(x, df: 2) }

      it 'obtains random numbers form a chi-squared distribution', :aggregate_failures do
        expect(y).to be_a(Numo::DFloat)
        expect(y.shape).to match(x.shape)
        expect(y.mean).to be_within(1e-2).of(2)
        expect(y.var).to be_within(1e-1).of(4)
      end
    end

    context 'when array type is SFloat' do
      let(:x) { Numo::SFloat.new(500, 600) }
      let(:y) { rng.chisquare(x, df: 2) }

      it 'obtains random numbers form a chi-squared distribution', :aggregate_failures do
        expect(y).to be_a(Numo::SFloat)
        expect(y.shape).to match(x.shape)
        expect(y.mean).to be_within(1e-2).of(2)
        expect(y.var).to be_within(1e-1).of(4)
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
      let(:x) { Numo::DFloat.new(500, 600) }
      let(:y) { rng.f(x, dfnum: 5, dfden: 10) }

      it 'obtains random numbers form a F-distribution', :aggregate_failures do
        expect(y).to be_a(Numo::DFloat)
        expect(y.shape).to match(x.shape)
        expect(y.mean).to be_within(1e-2).of(1.25)
        expect(y.var).to be_within(1e-1).of(1.354)
      end
    end

    context 'when array type is SFloat' do
      let(:x) { Numo::SFloat.new(500, 600) }
      let(:y) { rng.f(x, dfnum: 5, dfden: 10) }

      it 'obtains random numbers form a F-distribution', :aggregate_failures do
        expect(y).to be_a(Numo::SFloat)
        expect(y.shape).to match(x.shape)
        expect(y.mean).to be_within(1e-2).of(1.25)
        expect(y.var).to be_within(1e-1).of(1.354)
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

  describe '#lognormal' do
    context 'when array type is DFloat' do
      let(:x) { Numo::DFloat.new(500, 600) }
      let(:y) { rng.lognormal(x) }

      it 'obtains random numbers form a lognormal distribution', :aggregate_failures do
        expect(y).to be_a(Numo::DFloat)
        expect(y.shape).to match(x.shape)
        expect(y.mean).to be_within(1e-2).of(Math.exp(0.5))
        expect(y.var).to be_within(1e-1).of(Math.exp(2) - Math.exp(1))
      end
    end

    context 'when array type is SFloat' do
      let(:x) { Numo::SFloat.new(500, 600) }
      let(:y) { rng.lognormal(x) }

      it 'obtains random numbers form a lognormal distribution', :aggregate_failures do
        expect(y).to be_a(Numo::SFloat)
        expect(y.shape).to match(x.shape)
        expect(y.mean).to be_within(1e-2).of(Math.exp(0.5))
        expect(y.var).to be_within(1e-1).of(Math.exp(2) - Math.exp(1))
      end
    end

    context 'when loc and scale parameters are given' do
      let(:x) { Numo::DFloat.new(500, 800) }
      let(:y) { rng.lognormal(x, mean: 0.5, sigma: 1) }

      it 'obtains random numbers form a lognormal distribution along with given parameters', :aggregate_failures do
        expect(y.mean).to be_within(1e-2).of(Math.exp(1))
        expect(y.var).to be_within(1e-1).of(Math.exp(3) - Math.exp(2))
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
      let(:x) { Numo::DFloat.new(500, 600) }
      let(:y) { rng.standard_t(x, df: 10) }

      it "obtains random numbers form a Student's t-distribution", :aggregate_failures do
        expect(y).to be_a(Numo::DFloat)
        expect(y.shape).to match(x.shape)
        expect(y.mean).to be_within(1e-2).of(0)
        expect(y.var).to be_within(1e-2).of(1.25)
      end
    end

    context 'when array type is SFloat' do
      let(:x) { Numo::SFloat.new(500, 600) }
      let(:y) { rng.standard_t(x, df: 10) }

      it "obtains random numbers form a Student's t-distribution", :aggregate_failures do
        expect(y).to be_a(Numo::SFloat)
        expect(y.shape).to match(x.shape)
        expect(y.mean).to be_within(1e-2).of(0)
        expect(y.var).to be_within(1e-2).of(1.25)
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
