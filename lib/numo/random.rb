# frozen_string_literal: true

require 'numo/narray'

require_relative 'random/version'
require_relative 'random/randomext'

# Ruby/Numo (NUmerical MOdules)
module Numo
  # Numo::Random provides random number generation with several distributions for Numo::NArray.
  module Random
    # Generator is a class that generates random number with several distributions.
    #
    # @example
    #   require 'numo/random'
    #
    #   x = Numo::DFloat.new(100)
    #
    #   rng = Numo::Random::Generator.new
    #   rng.uniform(x, low: -1, high: 2)
    class Generator
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

      # Fills given array with uniformly distributed random values in the interval [low, high).
      #
      # @example
      #   require 'numo/random'
      #
      #   x = Numo::DFloat.new(100)
      #
      #   rng = Numo::Random::Generator.new
      #   rng.uniform(x, low: -1.5, high: 1.5)
      #
      # @param x [Numo::DFloat | Numo::SFloat] array filled with random values.
      # @param low [Float] lower boundary.
      # @param high [Float] upper boundary.
      def uniform(x, low: 0.0, high: 1.0)
        rng.uniform(x, low: low, high: high)
      end

      # Fills given array with random values according to the Cauchy (Lorentz) distribution.
      #
      # @example
      #   require 'numo/random'
      #
      #   x = Numo::DFloat.new(100)
      #
      #   rng = Numo::Random::Generator.new
      #   rng.cauchy(x, loc: 0.0, scale: 1.0)
      #
      # @param x [Numo::DFloat | Numo::SFloat] array filled with random values.
      # @param loc [Float] location parameter.
      # @param scale [Float] scale parameter.
      def cauchy(x, loc: 0.0, scale: 1.0)
        rng.cauchy(x, loc: loc, scale: scale)
      end

      # Fills given array with random values according to the Chi-squared distribution.
      #
      # @example
      #   require 'numo/random'
      #
      #   x = Numo::DFloat.new(100)
      #
      #   rng = Numo::Random::Generator.new
      #   rng.chisquare(x, df: 2.0)
      #
      # @param x [Numo::DFloat | Numo::SFloat] array filled with random values.
      # @param df [Float] degrees of freedom, must be > 0.
      def chisquare(x, df:)
        rng.chisquare(x, df: df)
      end

      # Fills given array with random values according to the F-distribution.
      #
      # @example
      #   require 'numo/random'
      #
      #   x = Numo::DFloat.new(100)
      #
      #   rng = Numo::Random::Generator.new
      #   rng.f(x, dfnum: 2.0, dfden: 4.0)
      #
      # @param x [Numo::DFloat | Numo::SFloat] array filled with random values.
      # @param dfnum [Float] degrees of freedom in numerator, must be > 0.
      # @param dfden [Float] degrees of freedom in denominator, must be > 0.
      def f(x, dfnum:, dfden:)
        rng.f(x, dfnum: dfnum, dfden: dfden)
      end

      # Fills given array with random values according to a normal (Gaussian) distribution.
      #
      # @example
      #   require 'numo/random'
      #
      #   x = Numo::DFloat.new(100)
      #
      #   rng = Numo::Random::Generator.new
      #   rng.normal(x, loc: 0.0, scale: 1.0)
      #
      # @param x [Numo::DFloat | Numo::SFloat] array filled with random values.
      # @param loc [Float] location parameter.
      # @param scale [Float] scale parameter.
      def normal(x, loc: 0.0, scale: 1.0)
        rng.normal(x, loc: loc, scale: scale)
      end

      # Fills given array with random values according to a log-normal distribution.
      #
      # @example
      #   require 'numo/random'
      #
      #   x = Numo::DFloat.new(100)
      #
      #   rng = Numo::Random::Generator.new
      #   rng.lognormal(x, mean: 0.0, sigma: 1.0)
      #
      # @param x [Numo::DFloat | Numo::SFloat] array filled with random values.
      # @param mean [Float] mean of normal distribution.
      # @param sigma [Float] standard deviation of normal distribution.
      def lognormal(x, mean: 0.0, sigma: 1.0)
        rng.lognormal(x, mean: mean, sigma: sigma)
      end

      # Fills given array with random values according to the Student's t-distribution.
      #
      # @example
      #   require 'numo/random'
      #
      #   x = Numo::DFloat.new(100)
      #
      #   rng = Numo::Random::Generator.new
      #   rng.standard_t(x, df: 8.0)
      #
      # @param x [Numo::DFloat | Numo::SFloat] array filled with random values.
      # @param df [Float] degrees of freedom, must be > 0.
      def standard_t(x, df:)
        rng.standard_t(x, df: df)
      end

      private

      attr_reader :rng
    end
  end
end
