# frozen_string_literal: true

# Ruby/Numo (NUmerical MOdules)
module Numo
  # Numo::Random provides random number generation with several distributions for Numo::NArray.
  module Random
    # Generator is a class that generates random number with several distributions.
    #
    # @example
    #   require 'numo/random'
    #
    #   rng = Numo::Random::Generator.new(seed: 496)
    #   x = rng.uniform(shape: [2, 5], low: -1, high: 2)
    #
    #   p x
    #   # Numo::DFloat#shape=[2,5]
    #   # [[1.90546, -0.543299, 0.673332, 0.759583, -0.40945],
    #   #  [0.334635, -0.0558342, 1.28115, 1.93644, -0.0689543]]
    class Generator # rubocop:disable Metrics/ClassLength
      # Returns random number generation algorithm.
      # @return [String]
      attr_accessor :algorithm

      # Creates a new random number generator.
      #
      # @param seed [Integer] random seed used to initialize the random number generator.
      # @param algorithm [String] random number generation algorithm.
      def initialize(seed: nil, algorithm: 'pcg64') # rubocop:disable Lint/UnusedMethodArgument
        @algorithm = 'pcg64'
        @rng = PCG64.new(seed: seed)
      end

      # Returns the seed of random number generator.
      #
      # @return [Integer]
      def seed
        rng.seed
      end

      # Sets the seed of random number generator.
      #
      # @param val [Integer] random seed.
      def seed=(val)
        rng.seed = val
      end

      # Returns random number with uniform distribution in the half-open interval [0, 1).
      #
      # @example
      #   require 'numo/random'
      #
      #   rng = Numo::Random::Generator.new
      #   v = rng.random
      #
      # @return [Float]
      def random
        rng.random
      end

      # Generates array consists of random values according to a binomial distribution.
      #
      # @example
      #   require 'numo/random'
      #
      #   rng = Numo::Random::Generator.new(seed: 42)
      #   x = rng.binomial(shape: 1000, n: 10, p: 0.4)
      #
      # @param shape [Integer | Array<Integer>] size of random array.
      # @param n [Integer] number of trials.
      # @param p [Float] probability of success.
      # @param dtype [Symbol] data type of random array.
      # @return [Numo::IntX | Numo::UIntX]
      def binomial(shape:, n:, p:, dtype: :int32)
        x = klass(dtype).new(shape)
        rng.binomial(x, n: n, p: p)
        x
      end

      # Generates array consists of random values according to a negative binomial distribution.
      #
      # @example
      #   require 'numo/random'
      #
      #   rng = Numo::Random::Generator.new(seed: 42)
      #   x = rng.negative_binomial(shape: 1000, n: 10, p: 0.4)
      #
      # @param shape [Integer | Array<Integer>] size of random array.
      # @param n [Integer] number of trials.
      # @param p [Float] probability of success.
      # @param dtype [Symbol] data type of random array.
      # @return [Numo::IntX | Numo::UIntX]
      def negative_binomial(shape:, n:, p:, dtype: :int32)
        x = klass(dtype).new(shape)
        rng.negative_binomial(x, n: n, p: p)
        x
      end

      # Generates array consists of random values according to a geometric distribution.
      #
      # @example
      #   require 'numo/random'
      #
      #   rng = Numo::Random::Generator.new(seed: 42)
      #   x = rng.geometric(shape: 1000, p: 0.4)
      #
      # @param shape [Integer | Array<Integer>] size of random array.
      # @param p [Float] probability of success on each trial.
      # @param dtype [Symbol] data type of random array.
      # @return [Numo::IntX | Numo::UIntX]
      def geometric(shape:, p:, dtype: :int32)
        x = klass(dtype).new(shape)
        rng.geometric(x, p: p)
        x
      end

      # Generates array consists of random values with an exponential distribution.
      #
      # @example
      #   require 'numo/random'
      #
      #   rng = Numo::Random::Generator.new
      #   x = rng.exponential(shape: 100, scale: 2)
      #
      # @param shape [Integer | Array<Integer>] size of random array.
      # @param scale [Float] scale parameter, lambda = 1.fdiv(scale).
      # @param dtype [Symbol] data type of random array.
      # @return [Numo::DFloat | Numo::SFloat]
      def exponential(shape:, scale: 1.0, dtype: :float64)
        x = klass(dtype).new(shape)
        rng.exponential(x, scale: scale)
        x
      end

      # Generates array consists of random values with a gamma distribution.
      #
      # @example
      #   require 'numo/random'
      #
      #   rng = Numo::Random::Generator.new
      #   x = rng.gamma(shape: 100, k: 9, scale: 0.5)
      #
      # @param shape [Integer | Array<Integer>] size of random array.
      # @param k [Float] shape parameter.
      # @param scale [Float] scale parameter.
      # @param dtype [Symbol] data type of random array.
      # @return [Numo::DFloat | Numo::SFloat]
      def gamma(shape:, k:, scale: 1.0, dtype: :float64)
        x = klass(dtype).new(shape)
        rng.gamma(x, k: k, scale: scale)
        x
      end

      # Generates array consists of random values according to the Gumbel distribution.
      #
      # @example
      #   require 'numo/random'
      #
      #   rng = Numo::Random::Generator.new
      #   x = rng.gumbel(shape: 100, loc: 0.0, scale: 1.0)
      #
      # @param shape [Integer | Array<Integer>] size of random array.
      # @param loc [Float] location parameter.
      # @param scale [Float] scale parameter.
      # @param dtype [Symbol] data type of random array.
      # @return [Numo::DFloat | Numo::SFloat]
      def gumbel(shape:, loc: 0.0, scale: 1.0, dtype: :float64)
        x = klass(dtype).new(shape)
        rng.gumbel(x, loc: loc, scale: scale)
        x
      end

      # Generates array consists of random values according to the Poisson distribution.
      #
      # @example
      #   require 'numo/random'
      #
      #   rng = Numo::Random::Generator.new(seed: 42)
      #   x = rng.poisson(shape: 1000, mean: 4)
      #
      # @param shape [Integer | Array<Integer>] size of random array.
      # @param mean [Float] mean of poisson distribution.
      # @param dtype [Symbol] data type of random array.
      # @return [Numo::IntX | Numo::UIntX]
      def poisson(shape:, mean: 1.0, dtype: :int32)
        x = klass(dtype).new(shape)
        rng.poisson(x, mean: mean)
        x
      end

      # Generates array consists of random values with the Weibull distribution.
      #
      # @example
      #   require 'numo/random'
      #
      #   rng = Numo::Random::Generator.new
      #   x = rng.weibull(shape: 100, k: 5, scale: 2)
      #
      # @param shape [Integer | Array<Integer>] size of random array.
      # @param k [Float] shape parameter.
      # @param scale [Float] scale parameter.
      # @param dtype [Symbol] data type of random array.
      # @return [Numo::DFloat | Numo::SFloat]
      def weibull(shape:, k:, scale: 1.0, dtype: :float64)
        x = klass(dtype).new(shape)
        rng.weibull(x, k: k, scale: scale)
        x
      end

      # Generates array consists of random integer values in the interval [0, n).
      #
      # @example
      #   require 'numo/random'
      #
      #   rng = Numo::Random::Generator.new(seed: 42)
      #   w = Numo::DFloat[0.1, 0.6, 0.2]
      #   x = rng.discrete(shape: [3, 10], weight: w)
      #
      #   p x
      #
      #   # Numo::Int32#shape=[3,10]
      #   # [[1, 1, 1, 1, 1, 1, 1, 1, 2, 1],
      #   #  [0, 1, 0, 1, 1, 0, 1, 1, 2, 1],
      #   #  [2, 1, 1, 1, 1, 2, 2, 1, 1, 2]]
      #
      # @param shape [Integer | Array<Integer>] size of random array.
      # @param weight [Numo::DFloat | Numo::SFloat] (shape: [n]) list of probabilities of each integer being generated.
      # @param dtype [Symbol] data type of random array.
      # @return [Numo::IntX | Numo::UIntX]
      def discrete(shape:, weight:, dtype: :int32)
        x = klass(dtype).new(shape)
        rng.discrete(x, weight: weight)
        x
      end

      # Generates array consists of uniformly distributed random values in the interval [low, high).
      #
      # @example
      #   require 'numo/random'
      #
      #   rng = Numo::Random::Generator.new
      #   x = rng.uniform(shape: 100, low: -1.5, high: 1.5)
      #
      # @param shape [Integer | Array<Integer>] size of random array.
      # @param low [Float] lower boundary.
      # @param high [Float] upper boundary.
      # @param dtype [Symbol] data type of random array.
      # @return [Numo::DFloat | Numo::SFloat]
      def uniform(shape:, low: 0.0, high: 1.0, dtype: :float64)
        x = klass(dtype).new(shape)
        rng.uniform(x, low: low, high: high)
        x
      end

      # Generates array consists of random values according to the Cauchy (Lorentz) distribution.
      #
      # @example
      #   require 'numo/random'
      #
      #   rng = Numo::Random::Generator.new
      #   x = rng.cauchy(shape: 100, loc: 0.0, scale: 1.0)
      #
      # @param shape [Integer | Array<Integer>] size of random array.
      # @param loc [Float] location parameter.
      # @param scale [Float] scale parameter.
      # @param dtype [Symbol] data type of random array.
      # @return [Numo::DFloat | Numo::SFloat]
      def cauchy(shape:, loc: 0.0, scale: 1.0, dtype: :float64)
        x = klass(dtype).new(shape)
        rng.cauchy(x, loc: loc, scale: scale)
        x
      end

      # Generates array consists of random values according to the Chi-squared distribution.
      #
      # @example
      #   require 'numo/random'
      #
      #   rng = Numo::Random::Generator.new
      #   x = rng.chisquare(shape: 100, df: 2.0)
      #
      # @param shape [Integer | Array<Integer>] size of random array.
      # @param df [Float] degrees of freedom, must be > 0.
      # @param dtype [Symbol] data type of random array.
      # @return [Numo::DFloat | Numo::SFloat]
      def chisquare(shape:, df:, dtype: :float64)
        x = klass(dtype).new(shape)
        rng.chisquare(x, df: df)
        x
      end

      # Generates array consists of random values according to the F-distribution.
      #
      # @example
      #   require 'numo/random'
      #
      #   rng = Numo::Random::Generator.new
      #   x = rng.f(shape: 100, dfnum: 2.0, dfden: 4.0)
      #
      # @param shape [Integer | Array<Integer>] size of random array.
      # @param dfnum [Float] degrees of freedom in numerator, must be > 0.
      # @param dfden [Float] degrees of freedom in denominator, must be > 0.
      # @param dtype [Symbol] data type of random array.
      # @return [Numo::DFloat | Numo::SFloat]
      def f(shape:, dfnum:, dfden:, dtype: :float64)
        x = klass(dtype).new(shape)
        rng.f(x, dfnum: dfnum, dfden: dfden)
        x
      end

      # Generates array consists of random values according to a normal (Gaussian) distribution.
      #
      # @example
      #   require 'numo/random'
      #
      #   rng = Numo::Random::Generator.new
      #   x = rng.normal(shape: 100, loc: 0.0, scale: 1.0)
      #
      # @param shape [Integer | Array<Integer>] size of random array.
      # @param loc [Float] location parameter.
      # @param scale [Float] scale parameter.
      # @param dtype [Symbol] data type of random array.
      # @return [Numo::DFloat | Numo::SFloat]
      def normal(shape:, loc: 0.0, scale: 1.0, dtype: :float64)
        x = klass(dtype).new(shape)
        rng.normal(x, loc: loc, scale: scale)
        x
      end

      # Generates array consists of random values according to a log-normal distribution.
      #
      # @example
      #   require 'numo/random'
      #
      #   rng = Numo::Random::Generator.new
      #   x = rng.lognormal(shape: 100, mean: 0.0, sigma: 1.0)
      #
      # @param shape [Integer | Array<Integer>] size of random array.
      # @param mean [Float] mean of normal distribution.
      # @param sigma [Float] standard deviation of normal distribution.
      # @param dtype [Symbol] data type of random array.
      # @return [Numo::DFloat | Numo::SFloat]
      def lognormal(shape:, mean: 0.0, sigma: 1.0, dtype: :float64)
        x = klass(dtype).new(shape)
        rng.lognormal(x, mean: mean, sigma: sigma)
        x
      end

      # Generates array consists of random values according to the Student's t-distribution.
      #
      # @example
      #   require 'numo/random'
      #
      #   rng = Numo::Random::Generator.new
      #   x = rng.standard_t(shape: 100, df: 8.0)
      #
      # @param shape [Integer | Array<Integer>] size of random array.
      # @param df [Float] degrees of freedom, must be > 0.
      # @param dtype [Symbol] data type of random array.
      # @return [Numo::DFloat | Numo::SFloat]
      def standard_t(shape:, df:, dtype: :float64)
        x = klass(dtype).new(shape)
        rng.standard_t(x, df: df)
        x
      end

      private

      attr_reader :rng

      def klass(dtype) # rubocop:disable Metrics/CyclomaticComplexity, Metrics/MethodLength
        case dtype.to_sym
        when :int8
          Numo::Int8
        when :int16
          Numo::Int16
        when :int32
          Numo::Int32
        when :int64
          Numo::Int64
        when :uint8
          Numo::UInt8
        when :uint16
          Numo::UInt16
        when :uint32
          Numo::UInt32
        when :uint64
          Numo::UInt64
        when :float32, :sfloat
          Numo::SFloat
        when :float64, :dfloat
          Numo::DFloat
        else
          raise ArgumentError, "wrong dtype is given: #{dtype}"
        end
      end
    end
  end
end
